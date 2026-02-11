```mermaid
sequenceDiagram
    actor User
    participant SendMoneyPage
    participant SendMoneyCubit
    participant SendMoneyUseCase
    participant WalletRepository
    participant TransactionRepository

    User ->> SendMoneyPage: Enter amount
    User ->> SendMoneyPage: Tap Submit
    SendMoneyPage ->> SendMoneyCubit: sendMoney(amount)
    SendMoneyCubit ->> SendMoneyUseCase: execute(amount)

    SendMoneyUseCase ->> WalletRepository: deductBalance()
    WalletRepository -->> SendMoneyUseCase: success

    SendMoneyUseCase ->> TransactionRepository: saveTransaction()
    TransactionRepository -->> SendMoneyUseCase: saved

    SendMoneyUseCase -->> SendMoneyCubit: success
    SendMoneyCubit -->> SendMoneyPage: Show Success BottomSheet
    
```