;; RewardVault - Engaging. Fair. Motivating.
;; A decentralized points and rewards system for community participation
;; Features: Activity rewards, point redemption, engagement tracking

;; ===================================
;; CONSTANTS AND ERROR CODES
;; ===================================

(define-constant ERR-NOT-AUTHORIZED (err u20))
(define-constant ERR-REWARD-NOT-FOUND (err u21))
(define-constant ERR-INSUFFICIENT-POINTS (err u22))
(define-constant ERR-REWARD-INACTIVE (err u23))
(define-constant ERR-INVALID-AMOUNT (err u24))
(define-constant ERR-ALREADY-CLAIMED (err u25))

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MAX-POINTS-PER-ACTION u1000)
(define-constant MIN-REWARD-COST u10)
(define-constant ACTIVITY-COOLDOWN u144) ;; ~1 day cooldown

;; ===================================
;; DATA VARIABLES
;; ===================================

(define-data-var platform-active bool true)
(define-data-var reward-counter uint u0)
(define-data-var total-points-issued uint u0)
(define-data-var total-rewards-claimed uint u0)

;; ===================================
;; TOKEN DEFINITIONS
;; ===================================

;; Points tokens for rewards
(define-fungible-token reward-points)

;; ===================================
;; DATA MAPS
;; ===================================

;; Available rewards
(define-map rewards
  uint
  {
    title: (string-ascii 64),
    description: (string-ascii 128),
    point-cost: uint,
    stx-value: uint,
    max-claims: uint,
    current-claims: uint,
    active: bool,
    created-by: principal
  }
)

;; User point balances and activity
(define-map user-activity
  principal
  {
    total-points: uint,
    points-spent: uint,
    rewards-claimed: uint,
    last-activity: uint,
    activity-streak: uint
  }
)

;; Daily activity tracking
(define-map daily-activity
  { user: principal, day: uint }
  {
    points-earned: uint,
    actions-completed: uint
  }
)

;; Reward claim history
(define-map user-claims
  { user: principal, reward-id: uint }
  {
    claimed-at: uint,
    points-spent: uint
  }
)

;; ===================================
;; PRIVATE HELPER FUNCTIONS
;; ===================================

(define-private (is-contract-owner (user principal))
  (is-eq user CONTRACT-OWNER)
)

(define-private (get-current-day)
  (/ burn-block-height ACTIVITY-COOLDOWN)
)

(define-private (has-claimed-reward (user principal) (reward-id uint))
  (is-some (map-get? user-claims { user: user, reward-id: reward-id }))
)

(define-private (can-earn-points (user principal))
  (match (map-get? user-activity user)
    activity-data
    (>= burn-block-height (+ (get last-activity activity-data) ACTIVITY-COOLDOWN))
    true
  )
)

(define-private (calculate-streak-bonus (streak uint))
  (if (<= streak u0)
    u1
    (if (<= streak u7)
      (+ u1 (/ streak u7))
      u2
    )
  )
)

;; ===================================
;; READ-ONLY FUNCTIONS
;; ===================================

(define-read-only (get-platform-info)
  {
    active: (var-get platform-active),
    total-rewards: (var-get reward-counter),
    points-issued: (var-get total-points-issued),
    rewards-claimed: (var-get total-rewards-claimed)
  }
)

(define-read-only (get-reward (reward-id uint))
  (map-get? rewards reward-id)
)

(define-read-only (get-user-activity (user principal))
  (map-get? user-activity user)
)

(define-read-only (get-user-points (user principal))
  (ft-get-balance reward-points user)
)

(define-read-only (get-daily-activity (user principal) (day uint))
  (map-get? daily-activity { user: user, day: day })
)

(define-read-only (get-user-claim (user principal) (reward-id uint))
  (map-get? user-claims { user: user, reward-id: reward-id })
)

;; ===================================
;; ADMIN FUNCTIONS
;; ===================================

(define-public (toggle-platform (active bool))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (var-set platform-active active)
    (print { action: "platform-toggled", active: active })
    (ok true)
  )
)

(define-public (create-reward
  (title (string-ascii 64))
  (description (string-ascii 128))
  (point-cost uint)
  (stx-value uint)
  (max-claims uint)
)
  (let (
    (reward-id (+ (var-get reward-counter) u1))
  )
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (>= point-cost MIN-REWARD-COST) ERR-INVALID-AMOUNT)
    (asserts! (> max-claims u0) ERR-INVALID-AMOUNT)
    
    ;; Create reward
    (map-set rewards reward-id {
      title: title,
      description: description,
      point-cost: point-cost,
      stx-value: stx-value,
      max-claims: max-claims,
      current-claims: u0,
      active: true,
      created-by: tx-sender
    })
    
    (var-set reward-counter reward-id)
    (print { action: "reward-created", reward-id: reward-id, title: title, point-cost: point-cost })
    (ok reward-id)
  )
)

(define-public (toggle-reward (reward-id uint) (active bool))
  (let (
    (reward-data (unwrap! (map-get? rewards reward-id) ERR-REWARD-NOT-FOUND))
  )
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    
    (map-set rewards reward-id (merge reward-data { active: active }))
    (print { action: "reward-toggled", reward-id: reward-id, active: active })
    (ok true)
  )
)

;; ===================================
;; POINTS EARNING FUNCTIONS
;; ===================================

(define-public (earn-activity-points (points uint) (activity-type (string-ascii 32)))
  (let (
    (current-day (get-current-day))
    (user-stats (default-to { total-points: u0, points-spent: u0, rewards-claimed: u0, last-activity: u0, activity-streak: u0 }
                            (map-get? user-activity tx-sender)))
    (daily-stats (default-to { points-earned: u0, actions-completed: u0 }
                             (map-get? daily-activity { user: tx-sender, day: current-day })))
    (streak-bonus (calculate-streak-bonus (get activity-streak user-stats)))
    (bonus-points (* points streak-bonus))
    (final-points (if (<= bonus-points MAX-POINTS-PER-ACTION) bonus-points MAX-POINTS-PER-ACTION))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (> points u0) ERR-INVALID-AMOUNT)
    (asserts! (can-earn-points tx-sender) ERR-NOT-AUTHORIZED)
    
    ;; Mint points to user
    (try! (ft-mint? reward-points final-points tx-sender))
    
    ;; Update user activity
    (map-set user-activity tx-sender (merge user-stats {
      total-points: (+ (get total-points user-stats) final-points),
      last-activity: burn-block-height,
      activity-streak: (+ (get activity-streak user-stats) u1)
    }))
    
    ;; Update daily activity
    (map-set daily-activity { user: tx-sender, day: current-day } {
      points-earned: (+ (get points-earned daily-stats) final-points),
      actions-completed: (+ (get actions-completed daily-stats) u1)
    })
    
    ;; Update global stats
    (var-set total-points-issued (+ (var-get total-points-issued) final-points))
    
    (print { action: "points-earned", user: tx-sender, points: final-points, activity: activity-type, streak-bonus: streak-bonus })
    (ok final-points)
  )
)

(define-public (award-bonus-points (recipient principal) (points uint) (reason (string-ascii 64)))
  (let (
    (user-stats (default-to { total-points: u0, points-spent: u0, rewards-claimed: u0, last-activity: u0, activity-streak: u0 }
                            (map-get? user-activity recipient)))
  )
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> points u0) ERR-INVALID-AMOUNT)
    
    ;; Mint bonus points
    (try! (ft-mint? reward-points points recipient))
    
    ;; Update user stats
    (map-set user-activity recipient (merge user-stats {
      total-points: (+ (get total-points user-stats) points)
    }))
    
    ;; Update global stats
    (var-set total-points-issued (+ (var-get total-points-issued) points))
    
    (print { action: "bonus-awarded", recipient: recipient, points: points, reason: reason })
    (ok true)
  )
)

;; ===================================
;; REWARD CLAIMING FUNCTIONS
;; ===================================

(define-public (claim-reward (reward-id uint))
  (let (
    (reward-data (unwrap! (map-get? rewards reward-id) ERR-REWARD-NOT-FOUND))
    (user-points (ft-get-balance reward-points tx-sender))
    (user-stats (default-to { total-points: u0, points-spent: u0, rewards-claimed: u0, last-activity: u0, activity-streak: u0 }
                            (map-get? user-activity tx-sender)))
  )
    (asserts! (var-get platform-active) ERR-NOT-AUTHORIZED)
    (asserts! (get active reward-data) ERR-REWARD-INACTIVE)
    (asserts! (>= user-points (get point-cost reward-data)) ERR-INSUFFICIENT-POINTS)
    (asserts! (< (get current-claims reward-data) (get max-claims reward-data)) ERR-REWARD-INACTIVE)
    (asserts! (not (has-claimed-reward tx-sender reward-id)) ERR-ALREADY-CLAIMED)
    
    ;; Burn points from user
    (try! (ft-burn? reward-points (get point-cost reward-data) tx-sender))
    
    ;; Transfer STX reward if available
    (if (> (get stx-value reward-data) u0)
      (try! (as-contract (stx-transfer? (get stx-value reward-data) tx-sender tx-sender)))
      true
    )
    
    ;; Record claim
    (map-set user-claims { user: tx-sender, reward-id: reward-id } {
      claimed-at: burn-block-height,
      points-spent: (get point-cost reward-data)
    })
    
    ;; Update reward claims
    (map-set rewards reward-id (merge reward-data {
      current-claims: (+ (get current-claims reward-data) u1)
    }))
    
    ;; Update user stats
    (map-set user-activity tx-sender (merge user-stats {
      points-spent: (+ (get points-spent user-stats) (get point-cost reward-data)),
      rewards-claimed: (+ (get rewards-claimed user-stats) u1)
    }))
    
    ;; Update global stats
    (var-set total-rewards-claimed (+ (var-get total-rewards-claimed) u1))
    
    (print { action: "reward-claimed", user: tx-sender, reward-id: reward-id, points-spent: (get point-cost reward-data) })
    (ok true)
  )
)

(define-public (fund-reward-vault (amount uint))
  (begin
    (asserts! (is-contract-owner tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    
    ;; Transfer STX to contract for rewards
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    (print { action: "vault-funded", amount: amount })
    (ok true)
  )
)

;; ===================================
;; INITIALIZATION
;; ===================================

(begin
  (print { action: "rewardvault-initialized", owner: CONTRACT-OWNER })
)