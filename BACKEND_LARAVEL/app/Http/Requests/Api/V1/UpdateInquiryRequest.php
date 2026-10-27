<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class UpdateInquiryRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return $this->user()?->can('inquiries.edit') ?? false;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'customer_id' => 'sometimes|nullable|integer|exists:customers,id',
            'source' => 'sometimes|in:whatsapp,phone,walk_in,email,referral,social_media,other',
            'contact_name' => 'sometimes|required|string|max:150',
            'contact_phone' => 'sometimes|nullable|string|max:30',
            'contact_email' => 'sometimes|nullable|email|max:150',
            'subject' => 'sometimes|required|string|max:180',
            'description' => 'sometimes|required|string|max:10000',
        ];
    }
}
