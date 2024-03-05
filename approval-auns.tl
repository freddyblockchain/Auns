#pragma version 8

const int PRICE_PER_BOX = 2500
const int BOX_MULTIPLIER = 400

if Txn.ApplicationID == 0:
    # Handle Create App
    exit(1)
end

switch Txn.OnCompletion:
    NoOp: main
    OptIn: opt_in
    CloseOut: close_out
    UpdateApplication: update_app
    DeleteApplication: delete_app
end

block opt_in:
    exit(0)
end

block close_out:
    exit(0)
end

block update_app:
    exit(0)
end

block delete_app:
    exit(0)
end

func check_sender_paid(key_length: int, value_length: int):
    assert(Gtxn[0].Receiver == Global.CurrentApplicationAddress)
    int cost = PRICE_PER_BOX + (BOX_MULTIPLIER * (key_length + value_length))
    assert(Gtxn[0].Amount >= (cost * 2))
    return 1
end

block main:
    switch Txn.ApplicationArgs[0]:
        "create_aans": create_aans
    end

    block create_aans:
        bytes requested_name = Txn.ApplicationArgs[1]
        bytes associated_account = Txn.Sender
        int box_length_name
        int box_length_address

        int key_length = len(requested_name)
        int value_length = len(associated_account)
        check_sender_paid(key_length, value_length)

        # make sure boxes are empty
        box_length_name, _ = box_get(requested_name) 
        assert(box_length_name == 0)
        box_length_address, _ = box_get(associated_account)
        assert(box_length_address == 0)

        # Add link from name to account, and other way around. 
        box_put(Txn.ApplicationArgs[1], Txn.Sender)
        box_put(Txn.Sender, Txn.ApplicationArgs[1])

        exit(1)
    end

end