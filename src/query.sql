   WITH TempGiftCard AS
(SELECT OrderTrackDate
      , OrderNum
      , GiftCardsSold = SUM(ItemPrice)
   FROM dbo.OrderItems
  WHERE ItemName = 'GIFT CARD'
    AND OrderTrackDate BETWEEN '12/7/2015' AND '12/8/2015'
  GROUP BY OrderTrackDate, OrderNum)
      , TempPayment AS
(SELECT OrderTrackDate
      , OrderNum
      , Coupons = SUM(CASE WHEN PaymentCoupon = - 1 THEN PaymentAmount ELSE 0 END)
      , Promo = SUM(CASE WHEN PaymentPromo = - 1 THEN PaymentAmount ELSE 0 END)
   FROM dbo.Payment
  WHERE OrderTrackDate BETWEEN '12/7/2015' AND '12/8/2015'
  GROUP BY OrderTrackDate, OrderNum)
 SELECT Hour = DATEPART(hour, OrderCloseTime)
      , OrderType
      , GuestCount = SUM(OrderGuests)
      , AvgPerGuest = ROUND(CASE WHEN SUM(OrderGuests) = 0 THEN 0 ELSE SUM(OrderSubTotal) / SUM(OrderGuests) END, 2)
      , Subtotal = SUM(OrderSubTotal)
      , Coupons = ISNULL(SUM(Coupons), 0) * - 1
      , Promo = ISNULL(SUM(Promo), 0) * - 1
      , Taxable = SUM(OrderSubTotal) - (SUM(CASE WHEN OrderTaxExempt = - 1 THEN OrderSubTotal ELSE 0 END) + SUM(OrderNonTaxableAmount))
      , NonTaxable = SUM(CASE WHEN OrderTaxExempt = - 1 THEN OrderSubTotal ELSE 0 END) + SUM(OrderNonTaxableAmount)
      , TaxCollected = ROUND(SUM(CASE WHEN OrderTaxExempt = 0 THEN OrderDueTax ELSE 0 END), 2)
      , TaxIncludedSales = SUM(OrderTaxableInc)
      , TaxIncluded = SUM(OrderTaxInc)
      , TotalNetSales = ROUND(SUM(OrderSubTotal) + SUM(OrderTaxableInc), 2)
      , TotalTax = ROUND(SUM(CASE WHEN OrderTaxExempt = 0 THEN OrderDueTax ELSE 0 END) + SUM(OrderTaxInc), 2)
      , GrossSales = ROUND(SUM(OrderSubTotal) + SUM(CASE WHEN OrderTaxExempt = 0 THEN OrderDueTax ELSE 0 END), 2)
      , GiftCardsSold = ISNULL(SUM(GiftCardsSold), 0)
   FROM dbo.OrderInfo
   LEFT JOIN TempPayment ON OrderInfo.OrderNum = TempPayment.OrderNum AND OrderInfo.OrderTrackDate = TempPayment.OrderTrackDate
   LEFT JOIN TempGiftCard ON OrderInfo.OrderNum = TempGiftCard.OrderNum AND OrderInfo.OrderTrackDate = TempGiftCard.OrderTrackDate
  WHERE OrderInfo.OrderTrackDate BETWEEN '12/7/2015' AND '12/8/2015' AND OrderType IS NOT NULL
  GROUP BY DATEPART(hour, OrderCloseTime), OrderType
  ORDER BY DATEPART(hour, OrderCloseTime), OrderType
 OPTION (RECOMPILE);
