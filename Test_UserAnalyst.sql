
create view data_set
AS 
select created_date, a.USER_ID, LOẠI_GIAO_DỊCH, GIÁ_TRỊ_GIAO_DỊCH, TÊN_SẢN_PHẨM, TUỔI, THÀNH_PHỐ, GIỚI_TÍNH
from 
    (
        select * from product_marketing_dataset
    ) a 
inner JOIN
    (
        select * from finhay_user
    ) b 
on a.USER_ID = b.USER_ID

-- USER DEMOGRAPHIC

--- Độ tuổi tham gia giao dịch nhiều nhất
WITH NHÓM_TUỔI
as 
    (
        SELECT USER_ID, TUỔI, COUNT(TUỔI) AS SỐ_LƯỢNG
        FROM data_set
        group by USER_ID, TUỔI
    )

select TUỔI, COUNT(USER_ID) SỐ_LƯỢNG
from NHÓM_TUỔI
group by TUỔI
order by SỐ_LƯỢNG DESC
-->> Độ tuổi tham gia nhiều nhất: 19 - 30

--- Thành phố có nhiều user nhất
WITH TP
as 
    (
        SELECT USER_ID, THÀNH_PHỐ, COUNT(THÀNH_PHỐ) AS SỐ_LƯỢNG
        FROM data_set
        group by USER_ID, THÀNH_PHỐ
    )

select THÀNH_PHỐ, COUNT(USER_ID) SỐ_LƯỢNG
from TP
group by THÀNH_PHỐ
order by SỐ_LƯỢNG DESC
-->> Thành phố HCM và HN là 2 tp tập trung nhiều user nhất

--- Giới tính
WITH GENDER
as 
    (
        SELECT USER_ID, GIỚI_TÍNH, COUNT(GIỚI_TÍNH) AS SỐ_LƯỢNG
        FROM data_set
        group by USER_ID, GIỚI_TÍNH
    )

select GIỚI_TÍNH, COUNT(USER_ID) SỐ_LƯỢNG
from GENDER
group by GIỚI_TÍNH
order by SỐ_LƯỢNG DESC
--->> Số lượng user Nam nhiều gấp đôi số lượng user Nữ, chiếm 2/3 tổng số lượng user


-- USER BEHAVIOR

--- Giá trị giao dịch trung bình nạp và rút của user
select AVG(CAST(GIÁ_TRỊ_GIAO_DỊCH AS bigint)) TB_RÚT
from data_set
where LOẠI_GIAO_DỊCH LIKE 'R%'

select AVG(CAST(GIÁ_TRỊ_GIAO_DỊCH AS bigint)) TB_NẠP
from data_set
where LOẠI_GIAO_DỊCH LIKE 'N%'

--- RFM (Recency, Frequency, Monetary) Segmentation
select
    USER_ID,
    DATEDIFF(DAY, MAX(CREATED_DATE), GETDATE()) AS recency,
    COUNT(*) AS frequency,
    SUM(cast(GIÁ_TRỊ_GIAO_DỊCH as bigint)) AS monetary
from data_set
group by USER_ID

--- Giá trị giao dịch của các loại sản phẩm
SELECT a.TÊN_SẢN_PHẨM, a.RUT, b.NAP, round(cast(RUT as float)/cast(NAP as float),3) TI_LE_RUTNAP
FROM 
    (
        select TÊN_SẢN_PHẨM, SUM(CAST(GIÁ_TRỊ_GIAO_DỊCH as bigint)) RUT
        from data_set
        where LOẠI_GIAO_DỊCH LIKE 'R%'
        group by TÊN_SẢN_PHẨM
    ) a 
JOIN
    (
        select TÊN_SẢN_PHẨM, SUM(CAST(GIÁ_TRỊ_GIAO_DỊCH as bigint)) NAP
        from data_set
        where LOẠI_GIAO_DỊCH LIKE 'N%'
        group by TÊN_SẢN_PHẨM
    ) b 
ON a.TÊN_SẢN_PHẨM = b.TÊN_SẢN_PHẨM
--->> Tài khoản tiền Finhay là sản phẩm có lượng giao dịch nhiều nhất. Hũ vàng là sản phẩm có giá trị giao dịch ít nhất
--->> Tài khoản tiền Finhay và Hũ vàng đang là 2 sản phẩm có tỉ lệ Rút ít hơn tỉ lệ Nạp. Ngược lại Tích luỹ và Chứng Khoánn có tỉ lệ Rút nhiều hơn thì lệ Nạp






