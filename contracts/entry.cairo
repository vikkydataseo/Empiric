from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem

struct Entry:
    member timestamp : felt
    member price : felt
    member asset : felt  # UTF-8 encoded string, e.g. "USD/ETH"
    member publisher : felt
end

func hash_entry{pedersen_ptr : HashBuiltin*}(entry : Entry) -> (hash : felt):
    let (h1) = hash2{hash_ptr=pedersen_ptr}(entry.asset, entry.publisher)
    let (h2) = hash2{hash_ptr=pedersen_ptr}(entry.price, h1)
    let (h3) = hash2{hash_ptr=pedersen_ptr}(entry.timestamp, h2)
    return (h3)
end

func aggregate_entries{range_check_ptr}(num_entries : felt, entries_ptr : Entry*) -> (price : felt):
    let (price) = entries_median(num_entries, entries_ptr)
    return (price)
end

func entries_median{range_check_ptr}(num_entries : felt, entries_ptr : Entry*) -> (price : felt):
    let (sorted_entries_ptr) = sort_entries_by_price(num_entries, entries_ptr)

    let (q, r) = unsigned_div_rem(num_entries, 2)
    let is_even = 1 - r

    if is_even == 0:
        let median_idx = num_entries - q - 1  # 0-indexed
        let median_entry = [sorted_entries_ptr + median_idx * Entry.SIZE]
        return (median_entry.price)
    end

    let median_idx_1 = num_entries - q - 1
    let median_entry_1 = [sorted_entries_ptr + median_idx_1 * Entry.SIZE]
    let median_idx_2 = median_idx_1 + 1
    let median_entry_2 = [sorted_entries_ptr + median_idx_2 * Entry.SIZE]

    let (mean_price) = average_entries_price(median_entry_1, median_entry_2)
    return (mean_price)
end

func sort_entries_by_price{range_check_ptr}(num_entries : felt, entries_ptr : Entry*) -> (
        sorted_entries_ptr : Entry*):
    let (entries_ptr_input : Entry*) = alloc()
    let (sorted_entries_ptr) = bubble_sort_entries_by_price(
        num_entries, entries_ptr, 0, 1, entries_ptr_input, 0)
    return (sorted_entries_ptr)
end

func bubble_sort_entries_by_price{range_check_ptr}(
        num_entries : felt, entries_ptr : Entry*, idx1 : felt, idx2 : felt,
        sorted_entries_ptr : Entry*, sorted_this_iteration : felt) -> (sorted_entries_ptr : Entry*):
    alloc_locals
    local entries_ptr : Entry* = entries_ptr
    local range_check_ptr = range_check_ptr

    if idx2 == num_entries:
        assert [sorted_entries_ptr + (idx2 - 1) * Entry.SIZE] = [entries_ptr + idx1 * Entry.SIZE]
        if sorted_this_iteration == 0:
            return (sorted_entries_ptr)
        end

        let (new_sorted_ptr : Entry*) = alloc()
        let (recursive_sorted_ptr) = bubble_sort_entries_by_price(
            num_entries, sorted_entries_ptr, 0, 1, new_sorted_ptr, 0)
        return (recursive_sorted_ptr)
    end
    let (is_ordered) = is_le(
        [entries_ptr + idx1 * Entry.SIZE].price, [entries_ptr + idx2 * Entry.SIZE].price)
    if is_ordered == 1:
        assert [sorted_entries_ptr + (idx2 - 1) * Entry.SIZE] = [entries_ptr + idx1 * Entry.SIZE]
        let (recursive_sorted_ptr) = bubble_sort_entries_by_price(
            num_entries, entries_ptr, idx2, idx2 + 1, sorted_entries_ptr, sorted_this_iteration)
        return (recursive_sorted_ptr)
    end
    assert [sorted_entries_ptr + (idx2 - 1) * Entry.SIZE] = [entries_ptr + idx2 * Entry.SIZE]
    let (recursive_sorted_ptr) = bubble_sort_entries_by_price(
        num_entries, entries_ptr, idx1, idx2 + 1, sorted_entries_ptr, 1)
    return (recursive_sorted_ptr)
end

func entries_mean{range_check_ptr}(
        num_entries : felt, entries_ptr : Entry*, idx : felt, remainder : felt) -> (
        price : felt, remainder : felt):
    alloc_locals
    let running_price = [entries_ptr + idx * Entry.SIZE].price
    let (local summand, new_remainder) = unsigned_div_rem(running_price + remainder, num_entries)
    if idx + 1 == num_entries:
        return (summand, new_remainder)
    end
    let (recursive_summand, recursive_remainder) = entries_mean(
        num_entries, entries_ptr, idx + 1, new_remainder)
    let price = summand + recursive_summand
    return (price, recursive_remainder)
end

func average_entries_price{range_check_ptr}(entry_1 : Entry, entry_2 : Entry) -> (price : felt):
    let (summand_1, r1) = unsigned_div_rem(entry_1.price, 2)
    let (summand_2, r2) = unsigned_div_rem(entry_2.price, 2)
    let (summand_3, r3) = unsigned_div_rem(r1 + r2, 2)

    let price = summand_1 + summand_2 + summand_3
    return (price)
end
