-- minimal schema placeholder (если нужно, замени на реальные миграции)
CREATE TABLE IF NOT EXISTS bookings (
  id SERIAL PRIMARY KEY,
  client_name TEXT,
  car_brand TEXT,
  car_number TEXT,
  phone_hash TEXT,
  point_id TEXT,
  date DATE,
  slot_time TEXT,
  status TEXT,
  created_at TIMESTAMP DEFAULT now()
);

-- Индексы для производительности
CREATE INDEX IF NOT EXISTS idx_bookings_date_time_point ON bookings (date, slot_time, point_id);
CREATE INDEX IF NOT EXISTS idx_bookings_phone_hash ON bookings (phone_hash);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings (status);
CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings (created_at DESC);
