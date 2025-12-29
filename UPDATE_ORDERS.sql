-- Update semua orders existing ke status 'dikirim'
UPDATE public.orders
SET status = 'dikirim'
WHERE status IN ('menunggu', 'dibayar', 'cancelled')
OR status IS NULL;

-- Verify the update
SELECT id, status, customer_name, total_price, created_at
FROM public.orders
ORDER BY created_at DESC
LIMIT 20;
