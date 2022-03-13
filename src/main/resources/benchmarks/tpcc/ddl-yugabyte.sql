DROP TABLE IF EXISTS history CASCADE;
DROP TABLE IF EXISTS new_order CASCADE;
DROP TABLE IF EXISTS order_line CASCADE;
DROP TABLE IF EXISTS oorder CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS district CASCADE;
DROP TABLE IF EXISTS stock CASCADE;
DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS warehouse CASCADE;

CREATE TABLE warehouse (
    w_id       int            NOT NULL,
    w_ytd      decimal(12, 2) NOT NULL,
    w_tax      decimal(4, 4)  NOT NULL,
    w_name     varchar(10)    NOT NULL,
    w_street_1 varchar(20)    NOT NULL,
    w_street_2 varchar(20)    NOT NULL,
    w_city     varchar(20)    NOT NULL,
    w_state    char(2)        NOT NULL,
    w_zip      char(9)        NOT NULL,
    PRIMARY KEY (w_id)
);

CREATE TABLE item (
    i_id    int           NOT NULL,
    i_name  varchar(24)   NOT NULL,
    i_price decimal(5, 2) NOT NULL,
    i_data  varchar(50)   NOT NULL,
    i_im_id int           NOT NULL,
    PRIMARY KEY (i_id)
);

CREATE TABLE stock (
    s_w_id       int           NOT NULL,
    s_i_id       int           NOT NULL,
    s_quantity   int           NOT NULL,
    s_ytd        decimal(8, 2) NOT NULL,
    s_order_cnt  int           NOT NULL,
    s_remote_cnt int           NOT NULL,
    s_data       varchar(50)   NOT NULL,
    s_dist_01    char(24)      NOT NULL,
    s_dist_02    char(24)      NOT NULL,
    s_dist_03    char(24)      NOT NULL,
    s_dist_04    char(24)      NOT NULL,
    s_dist_05    char(24)      NOT NULL,
    s_dist_06    char(24)      NOT NULL,
    s_dist_07    char(24)      NOT NULL,
    s_dist_08    char(24)      NOT NULL,
    s_dist_09    char(24)      NOT NULL,
    s_dist_10    char(24)      NOT NULL,
    PRIMARY KEY (s_w_id HASH, s_i_id ASC)
);

CREATE TABLE district (
    d_w_id      int            NOT NULL,
    d_id        int            NOT NULL,
    d_ytd       decimal(12, 2) NOT NULL,
    d_tax       decimal(4, 4)  NOT NULL,
    d_next_o_id int            NOT NULL,
    d_name      varchar(10)    NOT NULL,
    d_street_1  varchar(20)    NOT NULL,
    d_street_2  varchar(20)    NOT NULL,
    d_city      varchar(20)    NOT NULL,
    d_state     char(2)        NOT NULL,
    d_zip       char(9)        NOT NULL,
    PRIMARY KEY ((d_w_id, d_id) HASH)
);

CREATE TABLE customer (
    c_w_id         int            NOT NULL,
    c_d_id         int            NOT NULL,
    c_id           int            NOT NULL,
    c_discount     decimal(4, 4)  NOT NULL,
    c_credit       char(2)        NOT NULL,
    c_last         varchar(16)    NOT NULL,
    c_first        varchar(16)    NOT NULL,
    c_credit_lim   decimal(12, 2) NOT NULL,
    c_balance      decimal(12, 2) NOT NULL,
    c_ytd_payment  float          NOT NULL,
    c_payment_cnt  int            NOT NULL,
    c_delivery_cnt int            NOT NULL,
    c_street_1     varchar(20)    NOT NULL,
    c_street_2     varchar(20)    NOT NULL,
    c_city         varchar(20)    NOT NULL,
    c_state        char(2)        NOT NULL,
    c_zip          char(9)        NOT NULL,
    c_phone        char(16)       NOT NULL,
    c_since        timestamp      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    c_middle       char(2)        NOT NULL,
    c_data         varchar(500)   NOT NULL,
    PRIMARY KEY ((c_w_id, c_d_id) HASH, c_id)
);

CREATE TABLE history (
    h_c_id   int           NOT NULL,
    h_c_d_id int           NOT NULL,
    h_c_w_id int           NOT NULL,
    h_d_id   int           NOT NULL,
    h_w_id   int           NOT NULL,
    h_date   timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    h_amount decimal(6, 2) NOT NULL,
    h_data   varchar(24)   NOT NULL
);

CREATE TABLE oorder (
    o_w_id       int       NOT NULL,
    o_d_id       int       NOT NULL,
    o_id         int       NOT NULL,
    o_c_id       int       NOT NULL,
    o_carrier_id int                DEFAULT NULL,
    o_ol_cnt     int       NOT NULL,
    o_all_local  int       NOT NULL,
    o_entry_d    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ((o_w_id, o_d_id) HASH, o_id)
);

CREATE TABLE new_order (
    no_w_id int NOT NULL,
    no_d_id int NOT NULL,
    no_o_id int NOT NULL,
    PRIMARY KEY ((no_w_id, no_d_id) HASH, no_o_id)
);

CREATE TABLE order_line (
    ol_w_id        int           NOT NULL,
    ol_d_id        int           NOT NULL,
    ol_o_id        int           NOT NULL,
    ol_number      int           NOT NULL,
    ol_i_id        int           NOT NULL,
    ol_delivery_d  timestamp     NULL DEFAULT NULL,
    ol_amount      decimal(6, 2) NOT NULL,
    ol_supply_w_id int           NOT NULL,
    ol_quantity    decimal(6,2)  NOT NULL,
    ol_dist_info   char(24)      NOT NULL,
    PRIMARY KEY ((ol_w_id, ol_d_id) HASH, ol_o_id, ol_number)
);

CREATE INDEX idx_customer_name ON customer ((c_w_id, c_d_id) HASH, c_last, c_first);
CREATE UNIQUE INDEX idx_order ON oorder ((o_w_id, o_d_id) HASH, o_c_id, o_id DESC);


ALTER TABLE DISTRICT DROP CONSTRAINT IF EXISTS D_FKEY_W;
ALTER TABLE DISTRICT ADD CONSTRAINT D_FKEY_W FOREIGN KEY (D_W_ID) REFERENCES WAREHOUSE (W_ID) NOT VALID;

ALTER TABLE CUSTOMER DROP CONSTRAINT IF EXISTS C_FKEY_D;
ALTER TABLE CUSTOMER ADD CONSTRAINT C_FKEY_D FOREIGN KEY (C_W_ID, C_D_ID) REFERENCES DISTRICT (D_W_ID, D_ID) NOT VALID;

ALTER TABLE STOCK DROP CONSTRAINT IF EXISTS S_FKEY_W;
ALTER TABLE STOCK DROP CONSTRAINT IF EXISTS S_FKEY_I;
ALTER TABLE STOCK ADD CONSTRAINT S_FKEY_W FOREIGN KEY (S_W_ID) REFERENCES WAREHOUSE (W_ID) NOT VALID;
ALTER TABLE STOCK ADD CONSTRAINT S_FKEY_I FOREIGN KEY (S_I_ID) REFERENCES ITEM (I_ID) NOT VALID;

ALTER TABLE OORDER DROP CONSTRAINT IF EXISTS O_FKEY_C;
ALTER TABLE OORDER ADD CONSTRAINT O_FKEY_C FOREIGN KEY (O_W_ID, O_D_ID, O_C_ID) REFERENCES CUSTOMER (C_W_ID, C_D_ID, C_ID) NOT VALID;

ALTER TABLE NEW_ORDER DROP CONSTRAINT IF EXISTS NO_FKEY_O;
ALTER TABLE NEW_ORDER ADD CONSTRAINT NO_FKEY_O FOREIGN KEY (NO_W_ID, NO_D_ID, NO_O_ID) REFERENCES OORDER (O_W_ID, O_D_ID, O_ID) NOT VALID;

ALTER TABLE HISTORY DROP CONSTRAINT IF EXISTS H_FKEY_C;
ALTER TABLE HISTORY DROP CONSTRAINT IF EXISTS H_FKEY_D;
ALTER TABLE HISTORY ADD CONSTRAINT H_FKEY_C FOREIGN KEY (H_C_W_ID, H_C_D_ID, H_C_ID) REFERENCES CUSTOMER (C_W_ID, C_D_ID, C_ID) NOT VALID;
ALTER TABLE HISTORY ADD CONSTRAINT H_FKEY_D FOREIGN KEY (H_W_ID, H_D_ID) REFERENCES DISTRICT (D_W_ID, D_ID) NOT VALID;

ALTER TABLE ORDER_LINE DROP CONSTRAINT IF EXISTS OL_FKEY_O;
ALTER TABLE ORDER_LINE DROP CONSTRAINT IF EXISTS OL_FKEY_S;
ALTER TABLE ORDER_LINE ADD CONSTRAINT OL_FKEY_O FOREIGN KEY (OL_W_ID, OL_D_ID, OL_O_ID) REFERENCES OORDER (O_W_ID, O_D_ID, O_ID) NOT VALID;
ALTER TABLE ORDER_LINE ADD CONSTRAINT OL_FKEY_S FOREIGN KEY (OL_SUPPLY_W_ID, OL_I_ID) REFERENCES STOCK (S_W_ID, S_I_ID) NOT VALID;
