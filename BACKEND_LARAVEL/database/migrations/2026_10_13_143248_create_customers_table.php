<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Table des clients d'Africa Print Communication.
     * Supporte les particuliers et les entreprises.
     * Les 818 clients existants (Aronium) seront importés ici.
     */
    public function up(): void
    {
        Schema::create('customers', function (Blueprint $table) {
            $table->id();

            // Type de client
            $table->enum('type', ['individual', 'company'])->default('individual')
                  ->comment('Particulier ou entreprise');

            // Informations principales
            $table->string('name', 150)->comment('Nom complet (particulier) ou raison sociale (entreprise)');
            $table->string('trade_name', 150)->nullable()->comment('Nom commercial si différent de la raison sociale');
            $table->string('email', 150)->nullable()->unique();
            $table->string('phone', 30)->nullable();
            $table->string('phone_2', 30)->nullable()->comment('Numéro secondaire ou WhatsApp');

            // Informations entreprise
            $table->string('rccm', 80)->nullable()->comment('Registre du commerce');
            $table->string('nif', 80)->nullable()->comment('Numéro d\'identification fiscale');
            $table->string('website', 200)->nullable();
            $table->string('industry', 100)->nullable()->comment('Secteur d\'activité');

            // Segmentation & Fidélisation
            $table->enum('segment', ['vip', 'regular', 'occasional', 'new'])->default('new')
                  ->comment('Segment de fidélité client');
            $table->decimal('credit_limit', 12, 2)->default(0)
                  ->comment('Plafond de crédit autorisé (FCFA)');
            $table->integer('payment_days')->default(0)
                  ->comment('Délai de paiement accordé en jours');

            // Canal d'acquisition
            $table->enum('acquisition_channel', ['walk_in', 'whatsapp', 'phone', 'referral', 'social_media', 'other'])
                  ->default('walk_in');

            // Import depuis Aronium
            $table->string('aronium_id', 50)->nullable()->unique()
                  ->comment('Identifiant dans l\'ancien logiciel Aronium pour la migration');

            // Statut
            $table->boolean('is_active')->default(true);
            $table->text('notes')->nullable()->comment('Notes internes sur le client');

            // Audit
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();

            // Index pour la recherche rapide
            $table->index('name');
            $table->index('phone');
            $table->index('segment');
            $table->index('type');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('customers');
    }
};
