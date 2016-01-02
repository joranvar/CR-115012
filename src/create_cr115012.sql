CREATE TABLE OrderItems
( OrderNum int not null primary key
, OrderTrackDate date not null
, ItemPrice float not null
, ItemName varchar(100) not null
);

CREATE TABLE Payment
( id int not null primary key
, OrderNum int not null
, PaymentCoupon int not null
, PaymentPromo int not null
, PaymentAmount float not null
, OrderTrackDate date not null
);

CREATE TABLE OrderInfo
( OrderNum int not null primary key
, OrderCloseTime datetime not null
, OrderType int null
, OrderGuests int not null
, OrderSubTotal float not null
, OrderTaxExempt int not null
, OrderNonTaxableAmount float not null
, OrderTaxableInc float not null
, OrderTaxInc float not null
, OrderDueTax int not null
, OrderTrackDate date not null
);
