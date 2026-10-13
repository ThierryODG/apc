<?php

namespace App\Domain\Catalog\Actions;

use App\Models\PriceHistory;
use App\Models\PrintService;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class UpdateServicePriceAction
{
    /**
     * Met à jour le prix d'une prestation et enregistre l'historique d'audit.
     */
    public function execute(
        PrintService $service,
        float $newPrice,
        ?User $user = null,
        ?string $reason = null
    ): PrintService {
        return DB::transaction(function () use ($service, $newPrice, $user, $reason) {
            $oldPrice = (float) $service->unit_price;

            if ($oldPrice !== $newPrice) {
                PriceHistory::create([
                    'print_service_id' => $service->id,
                    'user_id' => $user?->id,
                    'old_price' => $oldPrice,
                    'new_price' => $newPrice,
                    'reason' => $reason,
                ]);

                $service->update([
                    'unit_price' => $newPrice,
                ]);
            }

            return $service->fresh();
        });
    }
}
