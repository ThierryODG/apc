<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Contacts additionnels d'un client (entreprise).
     * Ex : directeur commercial, comptable, responsable technique.
     */
    public function up(): void
    {
        Schema::create('customer_contacts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('customers')->cascadeOnDelete();

            $table->string('first_name', 80);
            $table->string('last_name', 80)->nullable();
            $table->string('position', 100)->nullable()->comment('Poste / fonction');
            $table->string('email', 150)->nullable();
            $table->string('phone', 30)->nullable();
            $table->string('phone_2', 30)->nullable();

            $table->boolean('is_primary')->default(false)->comment('Contact principal à solliciter');
            $table->boolean('receives_invoices')->default(false)->comment('Reçoit les factures par email');
            $table->boolean('receives_quotes')->default(false)->comment('Reçoit les devis par email');

            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index('customer_id');
            $table->index('email');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customer_contacts');
    }
};
