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
    assert(Gtxn[0].Amount >= cost)
    return 1
end

block main:
    switch Txn.ApplicationArgs[0]:
        "create_aun": create_aun
        "delete_aun": delete_aun
    end

    block create_aun:
        bytes requested_name = Txn.ApplicationArgs[1]
        bytes associated_account = Txn.Sender
        int box_length

        int key_length = len(requested_name)
        int value_length = len(associated_account)
        check_sender_paid(key_length, value_length)

        # make sure box is empty
        box_length, _ = box_get(requested_name) 
        assert(box_length == 0)
        box_put(Txn.ApplicationArgs[1], Txn.Sender)

        # some statements here
        #box put
        exit(1)
    end

    block delete_aun:
        bytes name_to_delete = Txn.ApplicationArgs[1]
        bytes box_content
        _, box_content = box_get(name_to_delete) 
        assert(Txn.Sender == box_content)
        exit(box_del(name_to_delete))
    end

end