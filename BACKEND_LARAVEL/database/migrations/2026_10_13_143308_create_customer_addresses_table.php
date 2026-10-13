<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Adresses de livraison et de facturation des clients.
     */
    public function up(): void
    {
        Schema::create('customer_addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('customers')->cascadeOnDelete();

            $table->enum('type', ['delivery', 'billing', 'both'])->default('both')
                  ->comment('Type d\'adresse : livraison, facturation, ou les deux');

            $table->string('label', 80)->nullable()->comment('Ex : Siège social, Entrepôt, Boutique');
            $table->string('address_line_1', 200);
            $table->string('address_line_2', 200)->nullable();
            $table->string('district', 100)->nullable()->comment('Quartier ou arrondissement');
            $table->string('city', 100)->default('Douala');
            $table->string('region', 100)->nullable();
            $table->string('country', 100)->default('Cameroun');

            // Géolocalisation optionnelle
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();

            $table->boolean('is_default')->default(false)->comment('Adresse par défaut pour ce type');
            $table->text('delivery_notes')->nullable()->comment('Instructions de livraison particulières');

            $table->timestamps();

            $table->index('customer_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_addresses');
    }
};
