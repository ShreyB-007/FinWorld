-- =====================================================
-- FINWORLD V1
-- PostgreSQL Database Schema
-- Draft for team review
-- =====================================================


-- =====================================================
-- 1. PERSON
-- Stores individuals participating in FinWorld
-- =====================================================

CREATE TABLE person (
    person_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(150) NOT NULL,
    dob DATE,

    CONSTRAINT pk_person
        PRIMARY KEY (person_id)
);


-- =====================================================
-- 2. PERSON_ROLE
-- Allows one person to have multiple roles
-- =====================================================

CREATE TABLE person_role (
    person_id BIGINT NOT NULL,
    role VARCHAR(20) NOT NULL,

    CONSTRAINT pk_person_role
        PRIMARY KEY (person_id, role),

    CONSTRAINT fk_person_role_person
        FOREIGN KEY (person_id)
        REFERENCES person(person_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_person_role
        CHECK (role IN ('EMPLOYER', 'EMPLOYEE'))
);


-- =====================================================
-- 3. BANK
-- Stores financial institutions
-- =====================================================

CREATE TABLE bank (
    bank_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(150) NOT NULL,

    CONSTRAINT pk_bank
        PRIMARY KEY (bank_id)
);


-- =====================================================
-- 4. MERCHANT
-- Stores businesses receiving payments
-- =====================================================

CREATE TABLE merchant (
    merchant_id BIGINT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100),

    CONSTRAINT pk_merchant
        PRIMARY KEY (merchant_id)
);


-- =====================================================
-- 5. ACCOUNT
-- Stores financial accounts
-- An account belongs to either a person or a merchant
-- =====================================================

CREATE TABLE account (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY,

    person_id BIGINT,
    merchant_id BIGINT,
    bank_id BIGINT NOT NULL,

    balance NUMERIC(18, 2) NOT NULL DEFAULT 0.00,

    account_type VARCHAR(30) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_account
        PRIMARY KEY (account_id),

    CONSTRAINT fk_account_person
        FOREIGN KEY (person_id)
        REFERENCES person(person_id),

    CONSTRAINT fk_account_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES merchant(merchant_id),

    CONSTRAINT fk_account_bank
        FOREIGN KEY (bank_id)
        REFERENCES bank(bank_id),

    CONSTRAINT chk_account_balance
        CHECK (balance >= 0),

    CONSTRAINT chk_account_status
        CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),

    CONSTRAINT chk_account_owner
        CHECK (
            (person_id IS NOT NULL AND merchant_id IS NULL)
            OR
            (person_id IS NULL AND merchant_id IS NOT NULL)
        )
);


-- =====================================================
-- 6. EVENT
-- Stores financial events and causal relationships
-- =====================================================

CREATE TABLE event (
    event_id BIGINT GENERATED ALWAYS AS IDENTITY,

    actor_id BIGINT NOT NULL,

    timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    event_type VARCHAR(50) NOT NULL,

    parameters JSONB NOT NULL DEFAULT '{}'::JSONB,

    causal_parent_id BIGINT,

    CONSTRAINT pk_event
        PRIMARY KEY (event_id),

    CONSTRAINT fk_event_actor
        FOREIGN KEY (actor_id)
        REFERENCES person(person_id),

    CONSTRAINT fk_event_parent
        FOREIGN KEY (causal_parent_id)
        REFERENCES event(event_id),

    CONSTRAINT chk_event_not_own_parent
        CHECK (
            causal_parent_id IS NULL
            OR causal_parent_id <> event_id
        )
);


-- =====================================================
-- 7. TRANSACTION_RECORD
-- Stores financial movements between accounts
-- =====================================================

CREATE TABLE transaction_record (
    transaction_id BIGINT GENERATED ALWAYS AS IDENTITY,

    source_account_id BIGINT NOT NULL,

    destination_account_id BIGINT NOT NULL,

    event_id BIGINT NOT NULL UNIQUE,

    timestamp TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    amount NUMERIC(18, 2) NOT NULL,

    mode_of_payment VARCHAR(30) NOT NULL,

    type VARCHAR(30) NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    CONSTRAINT pk_transaction_record
        PRIMARY KEY (transaction_id),

    CONSTRAINT fk_transaction_source
        FOREIGN KEY (source_account_id)
        REFERENCES account(account_id),

    CONSTRAINT fk_transaction_destination
        FOREIGN KEY (destination_account_id)
        REFERENCES account(account_id),

    CONSTRAINT fk_transaction_event
        FOREIGN KEY (event_id)
        REFERENCES event(event_id),

    CONSTRAINT chk_transaction_amount
        CHECK (amount > 0),

    CONSTRAINT chk_transaction_type
        CHECK (
            type IN (
                'PURCHASE',
                'TRANSFER',
                'SALARY',
                'REFUND'
            )
        ),

    CONSTRAINT chk_transaction_status
        CHECK (
            status IN (
                'PENDING',
                'SUCCESS',
                'FAILED',
                'REVERSED'
            )
        ),

    CONSTRAINT chk_transaction_accounts
        CHECK (source_account_id <> destination_account_id)
);


-- =====================================================
-- INDEXES
-- Help retrieve transaction and event histories
-- =====================================================

CREATE INDEX idx_account_person
    ON account(person_id);

CREATE INDEX idx_account_merchant
    ON account(merchant_id);

CREATE INDEX idx_transaction_source
    ON transaction_record(source_account_id);

CREATE INDEX idx_transaction_destination
    ON transaction_record(destination_account_id);

CREATE INDEX idx_transaction_timestamp
    ON transaction_record(timestamp);

CREATE INDEX idx_event_actor
    ON event(actor_id);

CREATE INDEX idx_event_timestamp
    ON event(timestamp);

CREATE INDEX idx_event_type
    ON event(event_type);


-- =====================================================
-- END OF FINWORLD V1 SCHEMA
-- =====================================================