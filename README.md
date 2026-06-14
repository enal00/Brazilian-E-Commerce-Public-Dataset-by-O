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



# 📌 What I Did (Exact Steps) #
- Filtered orders to order_status == 'delivered.
- Computed durations (hours) for each step:
* purchase → approved
* approved → carrier
* carrier → customer
* purchase → customer (total)
* estimated total
- Cleaned rows by removing any order with negative or missing durations.
- Filtered delayed orders only: where dur_purchase_to_customer > dur_estimated_total.
- Computed averages within the delayed subset for each step.
- Flagged each delayed order if its step duration > delayed‑subset average for that step.
- Counted flags and combinations (0 / 1 / 2 / 3 steps above delayed‑average) to identify likely culprits.

# 📊 Exact Counts #
- Delivered orders after cleaning: 95,082
- Delayed orders (actual > estimated): 7,792
- Delayed‑group averages (hours)
* purchase → approved: 12.05 h
* approved → carrier: 128.38 h
* carrier → customer: 616.34 h

# 📈 Flag Counts (Delayed Orders Only) #
- purchase → approved above delayed‑average: 2,390 (30.7%)
- approved → carrier above delayed‑average: 2,315 (29.7%)
- carrier → customer above delayed‑average: 3,538 (45.4%)

**➡️ The last‑mile step (carrier → customer) is the most frequent culprit.**

# 🔎 Combination Breakdown (Delayed Orders = 7,792) #
- Only purchase → approved: 839 (10.8%)
- Only approved → carrier: 1,153 (14.8%)
- Only carrier → customer: 2,163 (27.8%)
- purchase → approved & approved → carrier: 585 (7.5%)
- purchase → approved & carrier → customer: 798 (10.2%)
- approved → carrier & carrier → customer: 409 (5.3%)
- All three steps: 168 (2.2%)
- None above delayed‑average: 1,677 (21.5%)

**➡️ Most delayed orders (53.3%) show a single dominant step as the bottleneck, especially carrier → customer.**
**➡️ Multi‑step delays (pairs/triple) exist but are less common.**
