WITH TempGiftCard AS
(SELECT OrderTrackDate, OrderNum, SUM(ItemPrice) AS GiftCardsSold
    FROM RMArchive.dbo.OrderItems
    WHERE ItemName = 'GIFT CARD'
        AND OrderTrackDate BETWEEN '12/7/2015' AND '12/8/2015'
    GROUP BY OrderTrackDate, OrderNum),
TempPayment AS
(SELECT OrderNum, SUM(CASE WHEN PaymentCoupon = - 1 THEN PaymentAmount ELSE 0 END) AS Coupons,
                  SUM(CASE WHEN PaymentPromo = - 1 THEN PaymentAmount ELSE 0 END) AS Promo,
                  OrderTrackDate
    FROM RMArchive.dbo.Payment
    WHERE OrderTrackDate BETWEEN '12/7/2015' AND '12/8/2015'
    GROUP BY OrderNum, OrderTrackDate)
SELECT DATEPART(hour, OrderCloseTime) AS Hour,
       OrderType,
       SUM(OrderGuests) AS GuestCount,
       ROUND(CASE WHEN SUM(OrderGuests) = 0 THEN 0 ELSE SUM(OrderSubTotal) / SUM(OrderGuests) END, 2) AS AvgPerGuest,
       SUM(OrderSubTotal) AS Subtotal,
       ISNULL(SUM(Coupons), 0) * - 1 AS Coupons,
       ISNULL(SUM(Promo), 0) * - 1 AS Promo,
       SUM(OrderSubTotal) - (SUM(CASE WHEN OrderTaxExempt = - 1 THEN OrderSubTotal ELSE 0 END) + SUM(OrderNonTaxableAmount)) AS Taxable,
       SUM(CASE WHEN OrderTaxExempt = - 1 THEN OrderSubTotal ELSE 0 END) + SUM(OrderNonTaxableAmount) AS NonTaxable,
       ROUND(SUM(CASE WHEN OrderTaxExempt = 0 THEN OrderDueTax ELSE 0 END), 2) AS TaxCollected,
       SUM(OrderTaxableInc) AS TaxIncludedSales,
       SUM(OrderTaxInc) AS TaxIncluded,
       ROUND(SUM(OrderSubTotal) + SUM(OrderTaxableInc), 2) AS TotalNetSales,
       ROUND(SUM(CASE WHEN OrderTaxExempt = 0 THEN OrderDueTax ELSE 0 END) + SUM(OrderTaxInc), 2) AS TotalTax,
       ROUND(SUM(OrderSubTotal) + SUM(CASE WHEN OrderTaxExempt = 0 THEN OrderDueTax ELSE 0 END), 2) AS GrossSales,
       ISNULL(SUM(GiftCardsSold), 0) AS GiftCardsSold
FROM RMArchive.dbo.OrderInfo
LEFT JOIN TempPayment ON OrderInfo.OrderNum = TempPayment.OrderNum AND OrderInfo.OrderTrackDate = TempPayment.OrderTrackDate
LEFT JOIN TempGiftCard ON OrderInfo.OrderNum = TempGiftCard.OrderNum AND OrderInfo.OrderTrackDate = TempGiftCard.OrderTrackDate
WHERE OrderInfo.OrderTrackDate BETWEEN '12/7/2015' AND '12/8/2015' AND OrderType IS NOT NULL
GROUP BY DATEPART(hour, OrderCloseTime), OrderType
ORDER BY DATEPART(hour, OrderCloseTime), OrderType
OPTION (RECOMPILE);
