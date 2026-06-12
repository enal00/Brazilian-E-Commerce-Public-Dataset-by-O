# Brazilian-E-Commerce-Public-Dataset-by-O
Order Receiving Performance Analytics Dashboard. Analyze high-volume order transactions to identify order quality issues, customer behavior patterns, operational bottlenecks, and performance drivers across multiple sales channels

# Business Questions #
* Which sales channels generate the highest order volume?
* Which products have the highest cancellation rates?
* What drives delayed order fulfillment?


**Implement IQR-based outlier cleaning and delay flagging**
- Applied IQR cleaning to remove anomalous records (negative durations between purchase, approval, and delivery events).
- Defined delay as orders with total delivery duration exceeding the estimated target duration.
- Flagged delayed orders when stage durations (seller, seller-carrier, carrier) exceed their respective averages.
- Aggregated counts of delay cases by stage:
  • Seller (approval/admin, invoicing, warehousing, packing)
  • Seller-carrier (shipping handoff/dropping)
  • Carrier (carrier admin, shipping carrier)
- Provides a clear breakdown of bottlenecks contributing to delayed order fulfillment.
