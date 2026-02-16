```mermaid
sequenceDiagram
    actor User
    participant TransactionHistoryPage
    participant TransactionHistoryCubit
    participant FetchTransactionsUseCase
    participant TransactionRepository
    participant ApiService

    User ->> TransactionHistoryPage: View page / Refresh
    TransactionHistoryPage ->> TransactionHistoryCubit: fetchTransactions()
    TransactionHistoryCubit ->> FetchTransactionsUseCase: execute()
    FetchTransactionsUseCase ->> TransactionRepository: fetchAll()
    TransactionRepository ->> ApiService: get('/api/transactions')
    ApiService -->> TransactionRepository: List of transactions
    TransactionRepository -->> FetchTransactionsUseCase: List of transactions
    FetchTransactionsUseCase ->> FetchTransactionsUseCase: Sort by date (latest first)
    FetchTransactionsUseCase -->> TransactionHistoryCubit: Sorted list
    TransactionHistoryCubit -->> TransactionHistoryPage: TransactionHistoryLoaded(transactions)
    TransactionHistoryPage -->> User: Display transactions
```