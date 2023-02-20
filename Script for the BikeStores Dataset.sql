Select *
From BikeStores.sales.orders

Select
	ord.order_id,
	CONCAT(cus.first_name,' ', cus.last_name) As'customers',
	cus.city,
	cus.state,
	ord.order_date,
	SUM(ite.quantity) as 'total_units',
	SUM(ite.quantity * ite.list_price) as 'revenue',
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name, ' ', sta.last_name) as 'sales_rep'
FROM BikeStores.sales.orders ord
JOIN BikeStores.sales.customers cus
on ord.customer_id = cus.customer_id
JOIN BikeStores.sales.order_items ite
on ord.order_id = ite.order_id
JOIN BikeStores.production.products pro
on ite.product_id = pro.product_id
JOIN BikeStores.production.categories cat
ON pro.category_id = cat.category_id
JOIN BikeStores.sales.stores sto
ON ord.store_id = sto.store_id
JOIN BikeStores.sales.staffs sta
ON ord.staff_id = sta.staff_id
Group by
	ord.order_id,
	CONCAT(cus.first_name,' ', cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name, ' ', sta.last_name)
