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
        Schema::create('print_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained('service_categories')->cascadeOnDelete();
            $table->foreignId('department_id')->constrained('departments')->restrictOnDelete();
            $table->foreignId('unit_id')->constrained('units')->restrictOnDelete();
            $table->string('name', 150);
            $table->string('code', 50)->unique();
            $table->text('description')->nullable();
            $table->string('pricing_type', 30)->default('surface'); // surface, fixed_unit, flat_fee
            $table->decimal('unit_price', 12, 2);
            $table->decimal('min_surface', 8, 2)->default(0);
            $table->decimal('min_price', 12, 2)->default(0);
            $table->boolean('requires_dimensions')->default(true);
            $table->boolean('requires_file')->default(true);
            $table->integer('default_lead_time_hours')->default(24);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('print_services');
    }
};
