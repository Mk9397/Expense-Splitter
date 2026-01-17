import heapq
from typing import Dict, List


def get_participant_balances(
    participants: List[Dict], expenses: List[Dict]
) -> Dict[str, Dict]:
    """Calculate the balance for each participant based on expenses"""
    participant_map = {p["id"]: p["name"] for p in participants}
    balances = {
        pid: {"name": name, "total_paid": 0.0, "should_pay": 0.0, "balance": 0.0}
        for pid, name in participant_map.items()
    }

    for expense in expenses:
        amount = expense.get("amount", 0.0)
        paid_by = expense.get("paid_by")
        split_type = expense.get("split_type", "equal")
        excluded = set(expense.get("excluded", []))

        # Who participates in this expense?
        participants = [pid for pid in participant_map if pid not in excluded]
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
            share = round(amount / participant_count, 2)
            for mid in participants:
                if mid in balances:
                    balances[mid]["should_pay"] += share

    for data in balances.values():
        data["balance"] = data["total_paid"] - data["should_pay"]

    return balances


def get_settlement_transactions(balances: Dict[str, Dict]) -> List[Dict]:
    """Generate settlement transactions to balance accounts"""
    creditors = []  # max-heap → negative values
    debtors = []  # max-heap → negative values for abs(debt)
    TOLERANCE = 0.01

    for pid, data in balances.items():
        balance = round(data["balance"], 2)
        if balance > TOLERANCE:
            heapq.heappush(
                creditors, (-balance, data["name"], pid)
            )  # negative = max heap
        elif balance < -TOLERANCE:
            heapq.heappush(debtors, (balance, data["name"], pid))  # negative balance

    settlements = []

    while creditors and debtors:
        cred_amt_neg, cred_name, cred_id = heapq.heappop(creditors)
        debt_amt, debt_name, debt_id = heapq.heappop(debtors)

        cred_amt = -cred_amt_neg
        pay_amount = min(cred_amt, -debt_amt)

        settlements.append(
            {
                "from_id": debt_id,
                "from_name": debt_name,
                "to_id": cred_id,
                "to_name": cred_name,
                "amount": round(pay_amount, 2),
            }
        )

        # Update amounts
        cred_amt -= pay_amount
        debt_amt += pay_amount  # debt_amt becomes less negative

        # Move to next creditor or debtor if settled
        if cred_amt > 0.01:
            heapq.heappush(creditors, (-cred_amt, cred_name, cred_id))
        if debt_amt < -0.01:
            heapq.heappush(debtors, (debt_amt, debt_name, debt_id))

    return settlements
