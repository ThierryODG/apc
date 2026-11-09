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
        Schema::create('companies', function (Blueprint $table) {
            $table->id();
            $table->string('name')->default('Africa Print Communication');
            $table->string('legal_form', 50)->nullable();
            $table->string('ifu_number', 60)->nullable()->comment('Identifiant Fiscal Unique');
            $table->string('rccm_number', 60)->nullable()->comment('Registre du Commerce');
            $table->string('phone_primary', 50)->nullable();
            $table->string('phone_secondary', 50)->nullable();
            $table->string('email', 120)->nullable();
            $table->string('address')->nullable();
            $table->string('city', 100)->nullable();
            $table->string('currency', 20)->default('FCFA');
            $table->string('logo_path')->nullable();
            $table->text('receipt_header')->nullable();
            $table->text('receipt_footer')->nullable()->default('Merci de votre confiance ! Les travaux imprimés ne sont ni repris ni échangés.');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('companies');
    }
};
