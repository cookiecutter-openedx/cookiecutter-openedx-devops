/*---------------------------------------------------------------------------
 * written by:	Lawrence McDaniel
 *				      https://lawrencemcdaniel.com
 *
 * date:		July 2022
 *
 * usage:		incremental table-by-table migration of open edx
 *				  @source_db data from Koa native build to tutor Nutmeg.
 *---------------------------------------------------------------------------*/
SET @site_id = 4;
SET @source_db = '@source_db';
SET @dest_db = 'destination_db';

INSERT INTO @dest_db.ecommerce_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined, full_name, tracking_context, lms_user_id)
	SELECT	src.id,
			src.password,
			src.last_login,
			src.is_superuser,
			src.username,
			src.first_name,
			src.last_name,
			src.email,
			src.is_staff,
			src.is_active,
			src.date_joined,
			src.full_name,
			src.tracking_context,
			lms_user.id as lms_user_id
	FROM	@source_db.ecommerce_user src
			JOIN edxapp.auth_user lms_user ON (src.username = lms_user.username)
			LEFT JOIN @dest_db.ecommerce_user dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);


INSERT INTO @dest_db.address_useraddress (id, title, first_name, last_name, line1, line2, line3, line4, state, postcode, search_text, phone_number, notes, is_default_for_shipping, is_default_for_billing, num_orders_as_shipping_address, hash, date_created, country_id, user_id, num_orders_as_billing_address)
	SELECT	src_address.id,
			src_address.title,
			src_address.first_name,
			src_address.last_name,
			src_address.line1,
			src_address.line2,
			src_address.line3,
			src_address.line4,
			src_address.state,
			src_address.postcode,
			src_address.search_text,
			src_address.phone_number,
			src_address.notes,
			src_address.is_default_for_shipping,
			src_address.is_default_for_billing,
			src_address.num_orders_as_shipping_address,
			src_address.hash,
			src_address.date_created,
			src_address.country_id,
			src_address.user_id,
			src_address.num_orders_as_billing_address
	FROM	@source_db.address_useraddress src_address
			LEFT JOIN @dest_db.address_useraddress dest_address ON (src_address.id = dest_address.id)
	WHERE	(dest_address.id IS NULL);


INSERT INTO @dest_db.basket_basket (id, status, date_created, date_merged, date_submitted, owner_id, site_id)
	SELECT	src_basket.id,
			src_basket.status,
			src_basket.date_created,
			src_basket.date_merged,
			src_basket.date_submitted,
			src_basket.owner_id,
			@site_id as site_id
	FROM	@source_db.basket_basket src_basket
			LEFT JOIN @dest_db.basket_basket dest_basket ON (src_basket.id = dest_basket.id)
	WHERE	(dest_basket.id IS NULL);


INSERT INTO @dest_db.basket_basketattribute (id, value_text, attribute_type_id, basket_id)
	SELECT	src.id,
			src.value_text,
			src.attribute_type_id,
			src.basket_id
	FROM	@source_db.basket_basketattribute src
			LEFT JOIN @dest_db.basket_basketattribute dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.basket_line (id, line_reference, quantity, price_currency, price_excl_tax, price_incl_tax, date_created, basket_id, product_id, stockrecord_id)
	SELECT	src.id,
			src.line_reference,
			src.quantity,
			src.price_currency,
			src.price_excl_tax,
			src.price_incl_tax,
			src.date_created,
			src.basket_id,
			src.product_id,
			src.stockrecord_id
	FROM	@source_db.basket_line src
			LEFT JOIN @dest_db.basket_line dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.django_session (session_key, session_data, expire_date)
	SELECT	src.session_key,
			src.session_data,
			src.expire_date
	FROM	@source_db.django_session src
			LEFT JOIN @dest_db.django_session dest ON (src.session_key = dest.session_key)
	WHERE	(dest.session_key IS NULL);

INSERT INTO @dest_db.order_billingaddress (id, title, first_name, last_name, line1, line2, line3, line4, state, postcode, search_text, country_id)
	SELECT	src.id,
			src.title,
			src.first_name,
			src.last_name,
			src.line1,
			src.line2,
			src.line3,
			src.line4,
			src.state,
			src.postcode,
			src.search_text,
			src.country_id
	FROM	@source_db.order_billingaddress src
			LEFT JOIN @dest_db.order_billingaddress dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);


INSERT INTO @dest_db.order_order  (id, number, currency, total_incl_tax, total_excl_tax, shipping_incl_tax, shipping_excl_tax, shipping_method, shipping_code, status, guest_email, date_placed, basket_id, billing_address_id, shipping_address_id, site_id, user_id, partner_id)
	SELECT	src.id,
			src.number,
			src.currency,
			src.total_incl_tax,
			src.total_excl_tax,
			src.shipping_incl_tax,
			src.shipping_excl_tax,
			src.shipping_method,
			src.shipping_code,
			src.status,
			src.guest_email,
			src.date_placed,
			src.basket_id,
			src.billing_address_id,
			src.shipping_address_id,
			@site_id as site_id,
			src.user_id,
			src.partner_id
	FROM	@source_db.order_order src
			LEFT JOIN @dest_db.order_order dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.order_line (id, partner_name, partner_sku, partner_line_reference, partner_line_notes, title, upc, quantity, line_price_incl_tax, line_price_excl_tax, line_price_before_discounts_incl_tax, line_price_before_discounts_excl_tax, unit_cost_price, unit_price_incl_tax, unit_price_excl_tax, unit_retail_price, status, est_dispatch_date, order_id, partner_id, product_id, stockrecord_id, effective_contract_discount_percentage, effective_contract_discounted_price)
	SELECT	src.id,
			src.partner_name,
			src.partner_sku,
			src.partner_line_reference,
			src.partner_line_notes,
			src.title,
			src.upc,
			src.quantity,
			src.line_price_incl_tax,
			src.line_price_excl_tax,
			src.line_price_before_discounts_incl_tax,
			src.line_price_before_discounts_excl_tax,
			src.unit_cost_price,
			src.unit_price_incl_tax,
			src.unit_price_excl_tax,
			src.unit_retail_price,
			src.status,
			src.est_dispatch_date,
			src.order_id,
			src.partner_id,
			src.product_id,
			src.stockrecord_id,
			src.effective_contract_discount_percentage,
			src.effective_contract_discounted_price
	FROM	@source_db.order_line src
			LEFT JOIN @dest_db.order_line dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.order_lineprice (id, quantity, price_incl_tax, price_excl_tax, shipping_incl_tax, shipping_excl_tax, line_id, order_id)
	SELECT	src.id,
			src.quantity,
			src.price_incl_tax,
			src.price_excl_tax,
			src.shipping_incl_tax,
			src.shipping_excl_tax,
			src.line_id,
			src.order_id
	FROM	@source_db.order_lineprice src
			LEFT JOIN @dest_db.order_lineprice dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.order_historicalorder (id, number, currency, total_incl_tax, total_excl_tax, shipping_incl_tax, shipping_excl_tax, shipping_method, shipping_code, status, guest_email, date_placed, history_id, history_date, history_change_reason, history_type, basket_id, billing_address_id, history_user_id, partner_id, shipping_address_id, site_id, user_id)
	SELECT	src.id,
			src.number,
			src.currency,
			src.total_incl_tax,
			src.total_excl_tax,
			src.shipping_incl_tax,
			src.shipping_excl_tax,
			src.shipping_method,
			src.shipping_code,
			src.status,
			src.guest_email,
			src.date_placed,
			src.history_id,
			src.history_date,
			src.history_change_reason,
			src.history_type,
			src.basket_id,
			src.billing_address_id,
			src.history_user_id,
			src.partner_id,
			src.shipping_address_id,
			@site_id as site_id,
			src.user_id
	FROM	@source_db.order_historicalorder src
			LEFT JOIN @dest_db.order_historicalorder dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.order_historicalline (id, partner_name, partner_sku, partner_line_reference, partner_line_notes, title, upc, quantity, line_price_incl_tax, line_price_excl_tax, line_price_before_discounts_incl_tax, line_price_before_discounts_excl_tax, unit_cost_price, unit_price_excl_tax, unit_retail_price, status, est_dispatch_date, history_id, history_date, history_change_reason, history_type, history_user_id, order_id, partner_id, product_id, stockrecord_id, effective_contract_discount_percentage, effective_contract_discounted_price)
	SELECT	src.id,
			src.partner_name,
			src.partner_sku,
			src.partner_line_reference,
			src.partner_line_notes,
			src.title,
			src.upc,
			src.quantity,
			src.line_price_incl_tax,
			src.line_price_excl_tax,
			src.line_price_before_discounts_incl_tax,
			src.line_price_before_discounts_excl_tax,
			src.unit_cost_price,
			src.unit_price_excl_tax,
			src.unit_retail_price,
			src.status,
			src.est_dispatch_date,
			src.history_id,
			src.history_date,
			src.history_change_reason,
			src.history_type,
			src.history_user_id,
			src.order_id,
			src.partner_id,
			src.product_id,
			src.stockrecord_id,
			src.effective_contract_discount_percentage,
			src.effective_contract_discounted_price
	FROM	@source_db.order_historicalline src
			LEFT JOIN @dest_db.order_historicalline dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);


INSERT INTO @dest_db.order_orderstatuschange (id, old_status, new_status, date_created, order_id)
	SELECT	src.id,
			src.old_status,
			src.new_status,
            src.date_created,
            src.order_id
	FROM	@source_db.order_orderstatuschange src
			LEFT JOIN @dest_db.order_orderstatuschange dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.order_paymentevent  (id, amount, reference, date_created, event_type_id, order_id, shipping_event_id, processor_name)
	SELECT	src.id,
			src.amount,
			src.reference,
			src.date_created,
			src.event_type_id,
			src.order_id,
			src.shipping_event_id,
			src.processor_name
	FROM	@source_db.order_paymentevent src
			LEFT JOIN @dest_db.order_paymentevent dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.order_paymenteventquantity (id, quantity, event_id, line_id)
	SELECT	src.id,
			src.quantity,
			src.event_id,
			src.line_id
	FROM	@source_db.order_paymenteventquantity src
			LEFT JOIN @dest_db.order_paymenteventquantity dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.payment_paymentprocessorresponse (id, processor_name, transaction_id, response, created, basket_id)
	SELECT	src.id,
			src.processor_name,
            src.transaction_id,
            src.response,
            src.created,
			src.basket_id
	FROM	@source_db.payment_paymentprocessorresponse src
			LEFT JOIN @dest_db.payment_paymentprocessorresponse dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.payment_source (id, currency, amount_allocated, amount_debited, amount_refunded, reference, label, order_id, source_type_id, card_type)
	SELECT	src.id,
			src.currency,
			src.amount_allocated,
			src.amount_debited,
			src.amount_refunded,
			src.reference,
			src.label,
			src.order_id,
			src.source_type_id,
			src.card_type
	FROM	@source_db.payment_source src
			LEFT JOIN @dest_db.payment_source dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);

INSERT INTO @dest_db.social_auth_usersocialauth (id, provider, uid, extra_data, user_id)
	SELECT	src.id,
			src.provider,
            src.uid,
            src.extra_data,
            src.user_id
	FROM	@source_db.social_auth_usersocialauth src
			LEFT JOIN @dest_db.social_auth_usersocialauth dest ON (src.id = dest.id)
	WHERE	(dest.id IS NULL);
