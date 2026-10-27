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
        Schema::create('inquiries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('qualified_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('quote_sent_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('refused_by')->nullable()->constrained('users')->nullOnDelete();

            $table->string('source', 30);
            $table->string('contact_name', 150);
            $table->string('contact_phone', 30)->nullable();
            $table->string('contact_email', 150)->nullable();
            $table->string('subject', 180);
            $table->text('description');
            $table->string('status', 30)->default('new');
            $table->decimal('quote_amount', 12, 2)->nullable();
            $table->text('refusal_reason')->nullable();
            $table->timestamp('qualified_at')->nullable();
            $table->timestamp('quote_sent_at')->nullable();
            $table->timestamp('refused_at')->nullable();

            $table->timestamps();
            $table->index(['status', 'created_at']);
            $table->index(['source', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('inquiries');
    }
};
