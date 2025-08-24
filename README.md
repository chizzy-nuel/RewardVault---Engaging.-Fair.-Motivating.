# 🏆 RewardVault - Engaging. Fair. Motivating.

A decentralized points and rewards system built on Stacks blockchain that incentivizes community participation through activity-based rewards and redeemable prizes.

## 📋 Overview

RewardVault gamifies community engagement by rewarding users with points for activities, which can then be redeemed for valuable prizes. Build active communities with transparent, blockchain-based reward systems that motivate sustained participation.

## ✨ Key Features

### 🎯 Activity-Based Rewards
- Earn points for community activities and contributions
- Streak bonuses for consistent daily participation
- Cooldown system prevents point farming (1-day intervals)
- Maximum 1,000 points per action with streak multipliers

### 🏪 Reward Marketplace
- Admins create diverse rewards (digital goods, STX prizes, exclusive access)
- Point-based redemption system with limited availability
- STX value rewards paid directly from contract vault
- Track reward popularity and claim history

### 📊 Engagement Analytics
- Daily activity tracking per user
- Personal statistics (points earned, spent, rewards claimed)
- Activity streaks and participation patterns
- Platform-wide engagement metrics

### 💫 Gamification Elements
- Streak bonuses encourage daily participation
- Limited reward quantities create urgency
- Transparent point earning and spending history
- Community leaderboards through activity tracking

## 🏗️ Architecture

### Core Components
```clarity
rewards        -> Available prizes and redemption options
user-activity  -> Individual participation stats and streaks
daily-activity -> Day-by-day engagement tracking
user-claims    -> Reward redemption history
```

### Token System
- **Reward Points**: Fungible tokens earned through activities
- **STX Rewards**: Direct payments for high-value prizes
- **Streak System**: Multiplier bonuses for consistent participation

## 🚀 Getting Started

### For Community Members

1. **Earn Points**: Participate in community activities
   ```clarity
   (earn-activity-points points "posting")
   ```

2. **Build Streaks**: Daily participation increases point multipliers
3. **Redeem Rewards**: Exchange points for valuable prizes
   ```clarity
   (claim-reward reward-id)
   ```

### For Community Admins

1. **Create Rewards**: Set up attractive redemption options
   ```clarity
   (create-reward title description point-cost stx-value max-claims)
   ```

2. **Award Bonuses**: Recognize exceptional contributions
   ```clarity
   (award-bonus-points recipient points reason)
   ```

3. **Fund Vault**: Add STX for reward payouts
   ```clarity
   (fund-reward-vault amount)
   ```

## 📈 Example Scenarios

### Daily Engagement
```
1. Alice posts helpful content: earns 50 points (day 1, no bonus)
2. Bob comments regularly: earns 30 points + 1.2x streak = 36 points (day 5)
3. Charlie maintains 7-day streak: earns 100 points + 2x bonus = 200 points
4. All build toward valuable reward redemptions
```

### Reward Redemption
```
1. Admin creates "Exclusive NFT Access" reward: 500 points, 5 max claims
2. Dave accumulates 520 points over 2 weeks of participation
3. Dave redeems reward: spends 500 points, gains exclusive access
4. Only 4 claims remaining, creating urgency for other users
```

### Community Recognition
```
1. Eve provides exceptional help to new members
2. Admin awards 200 bonus points: "Outstanding community support"
3. Eve's contribution is recognized and incentivized
4. Other members motivated to provide similar value
```

## ⚙️ Configuration

### Point System
- **Maximum per Action**: 1,000 points with streak bonuses
- **Minimum Reward Cost**: 10 points for basic rewards
- **Activity Cooldown**: 1 day between point-earning activities
- **Streak Multipliers**: Up to 2x bonus for consistent participation

### Reward Management
- **Limited Quantities**: Each reward has maximum claim limits
- **STX Integration**: Rewards can include direct STX payments
- **Activity Types**: Flexible categorization (posting, commenting, helping, etc.)

## 🔒 Security Features

### Anti-Gaming Measures
- Daily cooldown prevents rapid point accumulation
- Maximum points per action with reasonable limits
- Admin-controlled bonus point distribution
- Transparent claim history prevents duplicate redemptions

### Access Control
- Only contract owner can create rewards and award bonuses
- Users can only earn points through legitimate activities
- Reward claims validated against point balances

### Error Handling
```clarity
ERR-NOT-AUTHORIZED (u20)     -> Insufficient permissions
ERR-REWARD-NOT-FOUND (u21)   -> Invalid reward ID
ERR-INSUFFICIENT-POINTS (u22) -> Not enough points for reward
ERR-REWARD-INACTIVE (u23)    -> Reward unavailable or sold out
ERR-INVALID-AMOUNT (u24)     -> Invalid point amounts
ERR-ALREADY-CLAIMED (u25)    -> Reward already redeemed by user
```

## 📊 Analytics

### Platform Metrics
- Total points issued across all activities
- Total rewards claimed by community
- Platform engagement status
- Reward creation and redemption rates

### User Statistics
- Individual point earning and spending history
- Activity streaks and participation patterns
- Rewards claimed and redemption preferences
- Daily activity tracking and trends

### Reward Performance
- Claim rates and popular reward types
- STX value distribution and vault status
- Limited quantity tracking and availability

## 🛠️ Development

### Prerequisites
- Clarinet CLI installed
- STX tokens for reward funding
- Community engagement platform integration

### Local Testing
```bash
# Validate contract
clarinet check

# Run comprehensive tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

### Integration Examples
```clarity
;; User earns points for activity
(contract-call? .rewardvault earn-activity-points u75 "helpful-comment")

;; Admin creates valuable reward
(contract-call? .rewardvault create-reward
  "Premium Discord Role"
  "Exclusive access to premium community channels"
  u300
  u0
  u50)

;; User redeems reward
(contract-call? .rewardvault claim-reward u1)

;; Check user activity
(contract-call? .rewardvault get-user-activity tx-sender)

;; Award special recognition
(contract-call? .rewardvault award-bonus-points
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
  u150
  "Community leadership")
```

## 🎯 Use Cases

### Community Platforms
- Discord server engagement rewards
- Forum participation incentives
- Social media community building
- Educational platform completion rewards

### Project Communities
- Open source contribution rewards
- Bug report and testing incentives
- Documentation and tutorial creation
- Community moderation recognition

### Business Applications
- Customer loyalty programs
- Employee recognition systems
- Beta testing participation rewards
- User-generated content incentives

## 📋 Quick Reference

### Core Functions
```clarity
;; Point Earning
earn-activity-points(points, activity-type) -> points-awarded
award-bonus-points(recipient, points, reason) -> success

;; Reward Management
create-reward(title, description, cost, stx-value, max-claims) -> reward-id
claim-reward(reward-id) -> success
toggle-reward(reward-id, active) -> success

;; Information Queries
get-reward(reward-id) -> reward-data
get-user-activity(user) -> activity-stats
get-user-points(user) -> point-balance
get-daily-activity(user, day) -> daily-stats
```

## 🚦 Deployment Guide

1. Deploy contract to target network
2. Fund reward vault with STX for prizes
3. Create initial reward offerings
4. Integrate with community platform
5. Launch engagement campaigns
6. Monitor participation and adjust rewards

## 🤝 Contributing

RewardVault welcomes community contributions:
- Gamification feature enhancements
- Anti-gaming mechanism improvements
- Analytics and reporting tools
- Integration guides and examples

---

**⚠️ Disclaimer**: RewardVault is gamification software for community engagement. Ensure fair reward distribution and understand point economics before deployment.
