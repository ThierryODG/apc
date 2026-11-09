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
        Schema::table('products', function (Blueprint $table) {
            $table->boolean('allow_dimensions')->default(false)->after('tax_rate');
            $table->boolean('length_field')->default(false)->after('allow_dimensions');
            $table->boolean('width_field')->default(false)->after('length_field');
            $table->string('length_label', 50)->nullable()->after('width_field');
            $table->string('width_label', 50)->nullable()->after('length_label');
            $table->decimal('default_length', 10, 2)->nullable()->after('width_label');
            $table->decimal('default_width', 10, 2)->nullable()->after('default_length');
        });

        Schema::table('order_items', function (Blueprint $table) {
            $table->decimal('length', 10, 2)->nullable()->after('quantity');
            $table->decimal('width', 10, 2)->nullable()->after('length');
            $table->decimal('surface_area', 10, 2)->nullable()->after('width');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('order_items', function (Blueprint $table) {
            $table->dropColumn(['length', 'width', 'surface_area']);
        });

        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn([
                'allow_dimensions',
                'length_field',
                'width_field',
                'length_label',
                'width_label',
                'default_length',
                'default_width',
            ]);
        });
    }
};
