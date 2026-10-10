# Demo
Account

Purpose:
Represent a financial account in the simulated world.

Attributes:
account_id
balance
account_type
status

Relationships:
Held by a bank.
Owned by a person or merchant.
Sends and receives transactions.

Rules:
Balance must obey the defined ledger invariants.
Closed accounts cannot execute permitted transactions.