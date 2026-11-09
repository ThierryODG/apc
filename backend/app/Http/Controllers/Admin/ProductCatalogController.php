<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductCategory;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductCatalogController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = ProductCategory::query()
            ->orderBy('name')
            ->get();

        $products = Product::query()
            ->with('category:id,name,code')
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'categories' => $categories,
            'products' => $products,
        ]);
    }

    public function storeCategory(Request $request): JsonResponse
    {
        $data = $request->validate([
            'code' => ['required', 'string', 'max:50', 'unique:product_categories,code'],
            'name' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $category = ProductCategory::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Catégorie créée avec succès.',
            'category' => $category,
        ], 201);
    }

    public function updateCategory(Request $request, ProductCategory $category): JsonResponse
    {
        $data = $request->validate([
            'code' => ['sometimes', 'string', 'max:50', 'unique:product_categories,code,' . $category->id],
            'name' => ['sometimes', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $category->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Catégorie mise à jour.',
            'category' => $category->fresh(),
        ]);
    }

    public function destroyCategory(ProductCategory $category): JsonResponse
    {
        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Catégorie supprimée.',
        ]);
    }

    public function storeProduct(Request $request): JsonResponse
    {
        $data = $request->validate([
            'category_id' => ['nullable', 'exists:product_categories,id'],
            'code' => ['required', 'string', 'max:50', 'unique:products,code'],
            'name' => ['required', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'unit' => ['nullable', 'string', 'max:30'],
            'unit_price' => ['nullable', 'numeric', 'min:0'],
            'tax_rate' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'is_active' => ['nullable', 'boolean'],
            'allow_dimensions' => ['nullable', 'boolean'],
            'length_field' => ['nullable', 'boolean'],
            'width_field' => ['nullable', 'boolean'],
            'length_label' => ['nullable', 'string', 'max:50'],
            'width_label' => ['nullable', 'string', 'max:50'],
            'default_length' => ['nullable', 'numeric', 'min:0'],
            'default_width' => ['nullable', 'numeric', 'min:0'],
        ]);

        $product = Product::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Produit ajouté au catalogue.',
            'product' => $product->fresh('category'),
        ], 201);
    }

    public function updateProduct(Request $request, Product $product): JsonResponse
    {
        $data = $request->validate([
            'category_id' => ['nullable', 'exists:product_categories,id'],
            'code' => ['sometimes', 'string', 'max:50', 'unique:products,code,' . $product->id],
            'name' => ['sometimes', 'string', 'max:150'],
            'description' => ['nullable', 'string'],
            'unit' => ['nullable', 'string', 'max:30'],
            'unit_price' => ['nullable', 'numeric', 'min:0'],
            'tax_rate' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'is_active' => ['nullable', 'boolean'],
            'allow_dimensions' => ['nullable', 'boolean'],
            'length_field' => ['nullable', 'boolean'],
            'width_field' => ['nullable', 'boolean'],
            'length_label' => ['nullable', 'string', 'max:50'],
            'width_label' => ['nullable', 'string', 'max:50'],
            'default_length' => ['nullable', 'numeric', 'min:0'],
            'default_width' => ['nullable', 'numeric', 'min:0'],
        ]);

        $product->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Produit mis à jour.',
            'product' => $product->fresh('category'),
        ]);
    }

    public function destroyProduct(Product $product): JsonResponse
    {
        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Produit supprimé du catalogue.',
        ]);
    }
}
