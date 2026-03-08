import dotenv from "dotenv";
import app from "./app";
import pool from "./config/database";
import { migrate } from "./migrate";

dotenv.config();

// Gunakan 8080 agar sinkron dengan Security Group & Dockerfile
const PORT = process.env.PORT || "8080"; 

pool
  .connect()
  .then(async (client) => {
    console.log("Successfully connected to RDS PostgreSQL");
    client.release(); 

    // Menjalankan migrasi otomatis untuk High Availability
    try {
      await migrate(pool);
      console.log("Database migration completed");
    } catch (migError) {
      console.error("Migration failed:", migError);
    }

    app.listen(PORT, () => {
      // Menggunakan 0.0.0.0 agar bisa diakses oleh ALB di dalam VPC
      console.log(`SportOn Backend is running on port ${PORT}`);
    });
  })
  .catch((error) => {
    console.error("Error connecting to RDS PostgreSQL:", error);
    process.exit(1); // Hentikan proses jika gagal konek ke DB
  });
