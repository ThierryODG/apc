<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('daily_registers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('fiscal_year_id')->constrained('fiscal_years')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('register_date');
            $table->dateTime('opened_at');
            $table->dateTime('closed_at')->nullable();
            $table->decimal('opening_balance', 12, 2)->default(0);
            $table->decimal('cash_sales_total', 12, 2)->default(0);
            $table->decimal('cash_in_total', 12, 2)->default(0);
            $table->decimal('cash_out_total', 12, 2)->default(0);
            $table->decimal('expected_closing_balance', 12, 2)->default(0);
            $table->decimal('actual_closing_balance', 12, 2)->nullable();
            $table->decimal('discrepancy', 12, 2)->default(0);
            $table->string('status', 20)->default('open'); // 'open', 'closed'
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['fiscal_year_id', 'register_date', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('daily_registers');
    }
};

