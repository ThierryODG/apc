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
        Schema::create('service_options', function (Blueprint $table) {
            $table->id();
            $table->foreignId('department_id')->nullable()->constrained('departments')->nullOnDelete();
            $table->string('name', 100);
            $table->string('code', 50)->unique();
            $table->text('description')->nullable();
            $table->string('price_type', 30)->default('fixed'); // fixed, per_unit, per_sqm, per_meter
            $table->decimal('unit_price', 12, 2)->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('print_service_service_option', function (Blueprint $table) {
            $table->id();
            $table->foreignId('print_service_id')->constrained('print_services')->cascadeOnDelete();
            $table->foreignId('service_option_id')->constrained('service_options')->cascadeOnDelete();
            $table->unique(['print_service_id', 'service_option_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('print_service_service_option');
        Schema::dropIfExists('service_options');
    }
};
