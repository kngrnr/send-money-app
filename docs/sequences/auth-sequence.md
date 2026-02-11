```mermaid
sequenceDiagram
    actor User
    participant LoginPage
    participant AuthCubit
    participant LoginUseCase
    participant AuthRepository

    User ->> LoginPage: Enter username & password
    LoginPage ->> AuthCubit: login()
    AuthCubit ->> LoginUseCase: execute()
    LoginUseCase ->> AuthRepository: authenticate()
    AuthRepository -->> LoginUseCase: success
    LoginUseCase -->> AuthCubit: authenticated
    AuthCubit -->> LoginPage: AuthenticatedState

```