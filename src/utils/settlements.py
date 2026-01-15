from typing import Dict, List


def get_member_balances(members: List[Dict], expenses: List[Dict]) -> Dict[str, Dict]:
    """Calculate the balance for each member based on expenses"""
    member_map = {m["id"]: m["name"] for m in members}
    balances = {
        mid: {"name": name, "total_paid": 0.0, "should_pay": 0.0, "balance": 0.0}
        for mid, name in member_map.items()
    }

    for expense in expenses:
        amount = expense.get("amount", 0.0)
        paid_by = expense.get("paid_by")
        split_type = expense.get("split_type", "equal")
        excluded = set(expense.get("excluded", []))

        # Who participates in this expense?
        participants = [mid for mid in member_map if mid not in excluded]
        participant_count = len(participants) or 1  # avoid division by zero

        # Credit the payer (even if personal)
        if paid_by and paid_by in balances:
            balances[paid_by]["total_paid"] += amount

        if split_type == "personal":
            # Only the payer should pay (if known)
            if paid_by and paid_by in balances:
                balances[paid_by]["should_pay"] += amount
            if paid_by and paid_by not in balances:
                print(
                    "Warning: Unknown payer", paid_by, "for expense", expense.get("id")
                )

        else:  # "equal" (default)
            share = amount / participant_count
            for mid in participants:
                if mid in balances:
                    balances[mid]["should_pay"] += share

    for data in balances.values():
        data["balance"] = data["total_paid"] - data["should_pay"]

    return balances


def get_settlement_transactions(balances: Dict[str, Dict]) -> List[Dict]:
    """Generate settlement transactions to balance accounts"""
    creditors = []
    debtors = []
    TOLERANCE = 0.01

    for mid, data in balances.items():
        balance = data["balance"]
        if balance > TOLERANCE:
            creditors.append((mid, data["name"], balance))
        elif balance < -TOLERANCE:
            debtors.append((mid, data["name"], -balance))  # store as positive for ease

    settlements = []

    c_index = 0
    d_index = 0

    creditors.sort(key=lambda x: x[2], reverse=True)  # biggest owed first
    debtors.sort(key=lambda x: x[2], reverse=True)  # biggest owes first

    while c_index < len(creditors) and d_index < len(debtors):
        creditor_id, creditor_name, creditor_owed = creditors[c_index]
        debtor_id, debtor_name, debtor_owes = debtors[d_index]

        settlement_amount = min(creditor_owed, debtor_owes)

        settlements.append(
            {
                "from_id": debtor_id,
                "from_name": debtor_name,
                "to_id": creditor_id,
                "to_name": creditor_name,
                "amount": settlement_amount,
            }
        )

        # Update amounts
        creditors[c_index] = (
            creditor_id,
            creditor_name,
            max(0, creditor_owed - settlement_amount),
        )
        debtors[d_index] = (
            debtor_id,
            debtor_name,
            max(0, debtor_owes - settlement_amount),
        )

        # Move to next creditor or debtor if settled
        if creditors[c_index][2] < TOLERANCE:
            c_index += 1
        if debtors[d_index][2] < TOLERANCE:
            d_index += 1

    return settlements
