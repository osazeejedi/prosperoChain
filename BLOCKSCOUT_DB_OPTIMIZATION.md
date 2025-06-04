# Blockscout Database Connection Optimization

This document explains the changes made to optimize Blockscout's database connections to address the "too many connections" error with the PostgreSQL database.

## Problem

Blockscout was hitting the "too many connections" error with the PostgreSQL database, even after increasing the connection limit to 47. This suggests that Blockscout's architecture requires more connections than initially estimated.

## Solution

We've implemented several optimizations in the `docker-compose.yaml` file to reduce the number of database connections used by Blockscout:

### 1. Connection Pool Size Reduction

```yaml
POOL_SIZE: "5"
ECTO_POOL_SIZE: "4"
```

- `POOL_SIZE`: Reduced from the default value (typically 10-20) to 5, limiting the main database connection pool.
- `ECTO_POOL_SIZE`: Set to 4, controlling Ecto's database connection pool size.

### 2. Database Timeout Increase

```yaml
DATABASE_TIMEOUT: "120000"
```

- Increased from the default (typically 60000ms) to 120000ms (2 minutes).
- Longer timeouts reduce connection churn by allowing operations more time to complete before timing out and reconnecting.

### 3. Indexer Optimization

```yaml
INDEXER_MEMORY_LIMIT: "2Gb"
INDEXER_BATCH_SIZE: "25"
```

- `INDEXER_MEMORY_LIMIT`: Increased from the default (typically 1Gb) to 2Gb, allowing the indexer to process more data in memory before requiring database access.
- `INDEXER_BATCH_SIZE`: Increased from the default (typically 10) to 25, processing more items per database transaction, reducing the total number of transactions.

### 4. Feature Disabling

```yaml
DISABLE_WRITE_API: "true"
DISABLE_STATS: "true"
DISABLE_KNOWN_TOKENS: "true"
```

- Disabled non-essential features that consume additional database connections:
  - Write API: Disabled as it's not needed for basic blockchain exploration.
  - Stats collection: Disabled to reduce database load.
  - Known tokens tracking: Disabled to reduce database queries.

### 5. Healthcheck Addition

```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "--proxy", "off", "http://localhost:4000"]
  interval: 10s
  timeout: 5s
  retries: 3
  start_period: 30s
```

- Added a healthcheck to monitor the Blockscout service.
- This helps Docker automatically restart the service if it becomes unresponsive.

### 6. Queue Parameters

```yaml
ECTO_QUEUE_TARGET: "10000"
ECTO_QUEUE_INTERVAL: "10000"
```

- `ECTO_QUEUE_TARGET`: Increased from 5000ms to 10000ms (10 seconds).
- `ECTO_QUEUE_INTERVAL`: Increased from 5000ms to 10000ms (10 seconds).
- These parameters allow database queries to wait in the queue longer before being dropped, which helps prevent "connection not available and request was dropped from queue" errors.
- The values were doubled from the previous configuration as the 5000ms setting was still resulting in dropped connections.

### 7. Further Connection Pool Reduction

```yaml
POOL_SIZE: "3"
ECTO_POOL_SIZE: "2"
```

- `POOL_SIZE`: Further reduced from 5 to 3, minimizing the main database connection pool.
- `ECTO_POOL_SIZE`: Reduced from 4 to 2, further limiting Ecto's database connection pool size.
- These aggressive reductions help ensure we stay well below the connection limit.

### 8. Disabling Multiple Non-Essential Components

```yaml
# Disable specific components causing connection issues
DISABLE_VERIFIED_CONTRACTS_COUNTER: "true"
DISABLE_BLOCK_REWARDS_VALIDATIONS: "true"
DISABLE_EXCHANGE_RATES: "true"
DISABLE_INDEXER_INTERNAL_TRANSACTIONS: "true"
DISABLE_INDEXER_PENDING_TRANSACTIONS: "true"
DISABLE_INDEXER_SANITIZE_BLOCK_CONSENSUS: "true"
DISABLE_TOKEN_INSTANCE_FETCHER: "true"
DISABLE_TOKEN_BALANCE_FETCHER: "true"
DISABLE_TOKEN_TRANSFERS_COUNTER: "true"
DISABLE_WITHDRAWALS_COUNTER: "true"
DISABLE_PENDING_TRANSACTIONS_COUNTER: "true"
DISABLE_AVERAGE_BLOCK_TIME: "true"
DISABLE_ADDRESS_COIN_BALANCES_COUNTER: "true"
DISABLE_INTERNAL_TRANSACTIONS_INDEXED_COUNTER: "true"
DISABLE_BRIDGE: "true"
DISABLE_BRIDGE_MARKET_CAP_UPDATE: "true"
DISABLE_HISTORICAL_DATA_FETCHING: "true"
```

- Disabled multiple non-essential components that were identified in the error logs as causing database connection issues.
- Each of these components creates its own database connections and performs queries that can contribute to connection pool exhaustion.
- While this reduces some functionality, it ensures the core blockchain explorer features remain operational.

### 9. Minimal Indexer Mode

```yaml
# Minimal mode settings
INDEXER_DISABLE_INTERNAL_TRANSACTIONS_FETCHER: "true"
INDEXER_DISABLE_PENDING_TRANSACTIONS_FETCHER: "true"
INDEXER_DISABLE_TOKEN_BALANCES: "true"
INDEXER_DISABLE_TOKEN_INSTANCE_FETCHER: "true"
INDEXER_DISABLE_COIN_BALANCES_FETCHER: "true"
INDEXER_DISABLE_CATALOGED_TOKEN_UPDATER_FETCHER: "true"
INDEXER_DISABLE_UNCLES_FETCHER: "true"
INDEXER_DISABLE_STAKING_POOLS_FETCHER: "true"
INDEXER_DISABLE_WITHDRAWALS_FETCHER: "true"
INDEXER_DISABLE_BLOCK_REWARD_FETCHER: "true"
INDEXER_DISABLE_EMPTY_BLOCKS_SANITIZER: "true"
INDEXER_DISABLE_REPLACED_TRANSACTION_FETCHER: "true"
```

- Configured Blockscout to run in a minimal indexer mode, focusing only on essential blockchain data.
- These settings disable various specialized indexers that create additional database connections.
- The core block and transaction indexing remains enabled to maintain basic explorer functionality.

## Expected Results

These optimizations should significantly reduce the number of database connections used by Blockscout, allowing it to operate within the 47 connection limit of the PostgreSQL database. The trade-off is that some features are disabled, and indexing might be slightly slower but more efficient in terms of database usage.

## Monitoring and Further Optimization

After implementing these changes, monitor the PostgreSQL database connection count to ensure it stays below the limit. If connection issues persist, consider:

1. Further reducing `POOL_SIZE` and `ECTO_POOL_SIZE`
2. Disabling additional features (e.g., `DISABLE_WEBAPP: "true"` if only API access is needed)
3. Increasing the database plan to allow more connections if the application requires them

## References

- [Blockscout Documentation](https://docs.blockscout.com/)
- [Ecto Database Connection Pool Documentation](https://hexdocs.pm/ecto/Ecto.Repo.html#module-shared-options)
