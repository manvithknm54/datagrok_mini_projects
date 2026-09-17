class BankAccount:
    """Base account class — deposit, withdraw, and balance tracking."""

    def __init__(self, owner, balance=0):
        self.owner = owner
        self.balance = balance

    def deposit(self, amount):
        if amount <= 0:
            raise ValueError("Deposit amount must be positive")
        self.balance += amount
        return self.balance

    def withdraw(self, amount):
        if amount <= 0:
            raise ValueError("Withdrawal amount must be positive")
        if amount > self.balance:
            raise ValueError(f"Insufficient funds: balance is {self.balance}, tried to withdraw {amount}")
        self.balance -= amount
        return self.balance

    def __str__(self):
        return f"{self.owner}'s account — Balance: {self.balance:.2f}"


class SavingsAccount(BankAccount):
    """Extends BankAccount with an interest rate and interest calculation."""

    def __init__(self, owner, balance=0, interest_rate=0.05):
        super().__init__(owner, balance)   # reuse parent's setup instead of duplicating it
        self.interest_rate = interest_rate

    def add_interest(self):
        interest = self.balance * self.interest_rate
        self.balance += interest
        return self.balance

    def __str__(self):
        return f"{self.owner}'s savings account — Balance: {self.balance:.2f} | Rate: {self.interest_rate*100:.1f}%"


if __name__ == "__main__":
    # Demo run — creates a SavingsAccount and exercises every method,
    # including deliberately triggering the insufficient-funds exception.

    account = SavingsAccount("Manvith", balance=1000, interest_rate=0.05)
    print(account)

    account.deposit(500)
    print(f"After deposit of 500: {account.balance:.2f}")

    account.withdraw(200)
    print(f"After withdrawal of 200: {account.balance:.2f}")

    # Deliberately trigger the insufficient-funds error path
    try:
        account.withdraw(999999)
    except ValueError as e:
        print(f"Expected error caught: {e}")

    account.add_interest()
    print(f"After interest applied: {account.balance:.2f}")

    print(account)
