create view rfm_segmentation_data as

with CLV as
( 
select
customername,
round(sum(sales),0) as monetary_value,
count( distinct ordernumber) as frequency_value,
sum(quantityordered) as total_qty_ordered,
max(str_to_date(orderdate, '%d/%m/%y' ) )as last_order_date,
datediff((select max(str_to_date(orderdate, '%d/%m/%y' ) ) from  sample_sales_data), max(str_to_date(orderdate, '%d/%m/%y' ) )) as recency_value
from sample_sales_data
group by customername) 
 select * from CLV;
rfm_score as(
select 
c.*, 
ntile(5) over(order by frequency_value) as frequency_score,
ntile(5) over(order by recency_value desc) as recency_score,
ntile(5) over(order by monetary_value) as monetary_score

 from CLV as c) ,
 
 rfm_combination as(
 select 
 r.*,
 frequency_score + recency_score + monetary_score As total_rfm_score,
 concat_ws( frequency_score, recency_score, monetary_score) as combined_rfm_score
 from rfm_score r),
 
 
  rfm_segment as
 (
 select 
 rc.*,
 CASE
    WHEN combined_RFM_Score IN (455, 515, 542, 544, 552, 553, 452, 545, 551, 554, 555)
        THEN 'Champions'

    WHEN combined_RFM_Score IN (344, 345, 353, 354, 355, 414, 415, 443, 451, 342, 351)
        THEN 'Loyal Customers'

    WHEN combined_RFM_Score IN (441, 442, 443, 444, 445, 354, 355)
        THEN 'Potential Loyalist'

    WHEN combined_RFM_Score IN (511, 512, 513, 521, 522)
        THEN 'New Customers'

    WHEN combined_RFM_Score IN (233, 234, 235, 243, 244, 245, 253, 254, 255, 323, 324, 325)
        THEN 'At Risk'

    WHEN combined_RFM_Score IN (111, 112, 113, 114, 115, 121, 122, 123, 124, 125, 
                       131, 132, 133, 134, 135, 141, 142, 143, 144, 145, 
                       151, 152, 153, 154, 155)
        THEN 'Lost Customers'

    ELSE 'Other'
END AS Customer_Segment

 from rfm_combination rc) 
 
 select 
 customer_segment,
 sum(monetary_value) as total_spending,
 round(avg(monetary_value), 0) as average_spending,
 sum(frequency_value) as total_order,
 sum(total_qty_ordered) as quantity_ordered
 from rfm_segmentation_data
 group by customer_segment;
 
 select * from rfm_segmentation_data;
 
