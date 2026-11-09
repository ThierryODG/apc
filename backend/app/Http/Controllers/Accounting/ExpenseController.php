<?php

namespace App\Http\Controllers\Accounting;

use App\Http\Controllers\Controller;
use App\Http\Requests\Accounting\StoreExpenseRequest;
use App\Models\CashFlow;
use App\Models\Expense;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ExpenseController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');

        $query = Expense::where('fiscal_year_id', $fiscalYear->id)
            ->with('user:id,name')
            ->orderByDesc('expense_date');

        if ($category = $request->input('category')) {
            $query->where('category', $category);
        }

        $expenses = $query->paginate($request->input('per_page', 25));

        return response()->json([
            'success' => true,
            'expenses' => $expenses,
        ]);
    }

    public function store(StoreExpenseRequest $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $user = $request->user();

        return DB::transaction(function () use ($request, $fiscalYear, $user) {
            $count = Expense::where('fiscal_year_id', $fiscalYear->id)->count() + 1;
            $expenseNumber = sprintf('DEP-%s-%05d', str_replace(['/', ' '], '-', $fiscalYear->code), $count);

            $data = $request->validated();
            $data['fiscal_year_id'] = $fiscalYear->id;
            $data['user_id'] = $user->id;
            $data['expense_number'] = $expenseNumber;

            $expense = Expense::create($data);

            // Création automatique de la sortie de caisse correspondante
            CashFlow::create([
                'fiscal_year_id' => $fiscalYear->id,
                'user_id' => $user->id,
                'flow_type' => 'out',
                'category' => 'charge_exploitation',
                'amount' => $expense->amount,
                'payment_method' => $expense->payment_method,
                'reference_type' => 'expense',
                'reference_id' => $expense->id,
                'description' => "Dépense {$expense->expense_number} : {$expense->category} ({$expense->beneficiary})",
                'flow_date' => Carbon::parse($expense->expense_date),
            ]);

            return response()->json([
                'success' => true,
                'message' => "Dépense {$expense->expense_number} enregistrée avec succès.",
                'expense' => $expense,
            ], 201);
        });
    }
}
