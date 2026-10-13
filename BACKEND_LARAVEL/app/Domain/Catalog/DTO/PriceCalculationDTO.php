<?php

namespace App\Domain\Catalog\DTO;

class PriceCalculationDTO
{
    /**
     * @param int $serviceId
     * @param float $quantity
     * @param float|null $widthCm
     * @param float|null $heightCm
     * @param array<int> $optionIds
     */
    public function __construct(
        public readonly int $serviceId,
        public readonly float $quantity = 1.0,
        public readonly ?float $widthCm = null,
        public readonly ?float $heightCm = null,
        public readonly array $optionIds = [],
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            serviceId: (int) $data['service_id'],
            quantity: isset($data['quantity']) ? (float) $data['quantity'] : 1.0,
            widthCm: isset($data['width_cm']) ? (float) $data['width_cm'] : null,
            heightCm: isset($data['height_cm']) ? (float) $data['height_cm'] : null,
            optionIds: isset($data['option_ids']) && is_array($data['option_ids']) ? $data['option_ids'] : [],
        );
    }
}
