DECLARE @startDate date = '2015-12-07';
DECLARE @endDate date = '2015-12-08';

IF OBJECT_ID(N'tempdb..#TempGiftCard') IS NOT NULL DROP TABLE #TempGiftCard;
SELECT OrderTrackDate
     , OrderNum
     , GiftCardsSold = SUM(ItemPrice)
  INTO #TempGiftCard
  FROM dbo.OrderItems
 WHERE ItemName = 'GIFT CARD'
   AND OrderTrackDate BETWEEN @startDate AND @endDate
 GROUP BY OrderTrackDate, OrderNum;

IF OBJECT_ID(N'tempdb..#TempPayment') IS NOT NULL DROP TABLE #TempPayment;
SELECT OrderTrackDate
     , OrderNum
     , Coupons = SUM(CASE WHEN PaymentCoupon = - 1 THEN PaymentAmount ELSE 0 END)
     , Promo = SUM(CASE WHEN PaymentPromo = - 1 THEN PaymentAmount ELSE 0 END)
  INTO #TempPayment
  FROM dbo.Payment
 WHERE OrderTrackDate BETWEEN @startDate AND @endDate
 GROUP BY OrderTrackDate, OrderNum;

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
  LEFT JOIN #TempPayment ON OrderInfo.OrderNum = #TempPayment.OrderNum AND OrderInfo.OrderTrackDate = #TempPayment.OrderTrackDate
  LEFT JOIN #TempGiftCard ON OrderInfo.OrderNum = #TempGiftCard.OrderNum AND OrderInfo.OrderTrackDate = #TempGiftCard.OrderTrackDate
 WHERE OrderInfo.OrderTrackDate BETWEEN @startDate AND @endDate AND OrderType IS NOT NULL
 GROUP BY DATEPART(hour, OrderCloseTime), OrderType
 ORDER BY DATEPART(hour, OrderCloseTime), OrderType
OPTION (RECOMPILE);
