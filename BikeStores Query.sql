Select 
	ord.order_id,
	concat(cus.first_name, ' ', cus.last_name) as 'customer',
	cus.city,
	cus.state,
	ord.order_date,
	sum(ite.quantity) as 'total_units',
	sum(ite.quantity * ite.list_price) as 'revenue',
	pro.product_name,
	cat.category_name,
	sto.store_name,
	concat(sta.first_name, ' ', + sta.last_name) as 'sales_rep',
	bra.brand_name
From sales.orders ord
Join sales.customers cus
On ord.customer_id = cus.customer_id
Join sales.order_items ite
On ord.order_id = ite.order_id
Join production.products pro
On ite.product_id = pro.product_id
Join production.categories cat
On pro.category_id = cat.category_id
Join sales.stores sto
On ord.store_id = sto.store_id
Join sales.staffs sta
On ord.staff_id = sta.staff_id
Join production.brands bra
On pro.brand_id = bra.brand_id
Group By
	ord.order_id,
	concat(cus.first_name, ' ', cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	pro.product_name,
	cat.category_name,
	sto.store_name,
	concat(sta.first_name, ' ', + sta.last_name),
	bra.brand_name