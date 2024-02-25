// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// gas const : 1878089

contract Events {
    struct node {
        address User;
        bytes32 next;
    }

    string[3] status = ["scheduled", "in progress", "completed"];

    function checkParticipation(address User, bytes32 eventId)
        internal
        view
        returns (bool)
    {
        for (
            uint256 i = 0;
            i < DetailsOfEvent[eventId].participant.length;
            i++
        ) {
            if (DetailsOfEvent[eventId].participant[i] == User) {
                return true;
            }
        }

        return false;
    }

    function updateParticipants(bytes32 eventId) internal {
        while (DetailsOfEvent[eventId].participant.length != 0) {
            DetailsOfEvent[eventId].participant.pop();
        }
        bytes32 p = UserEvent[eventId].head;
        while (p != 0) {
            DetailsOfEvent[eventId].participant.push(
                UserEvent[eventId].Participants[p].User
            );
            p = UserEvent[eventId].Participants[p].next;
        }
    }

    /*
    Create event :
Event Structure
* Event name 
* Event-time 
* location 
* sport name
* organizer-Id 
* event-Id 
* Status
* participants[]
* Maximum participants
* Participants in WaitingList

    */

    struct Event {
        string EventName;
        string Date;
        string Time;
        string Location;
        string SportName;
        address OrganiserId;
        bytes32 EventId;
        string Status;
        uint256 MAX_PARTICIPANTS_LIMIT;
        uint256 Participants_WaitingList;
        mapping(bytes32 => node) Participants;
        bytes32 head;
        uint256 length;
    }

    struct EventDetails {
        string EventName;
        string Date;
        string Time;
        string Location;
        string SportName;
        address OrganiserId;
        bytes32 EventId;
        string Status;
        address[] participant;
        uint256 MAX_PARTICIPANTS_LIMIT;
        uint256 Participants_WaitingList;
    }

    event EventCreated(
        string indexed Name,
        uint256 timestamp,
        string indexed sportsName,
        bytes32 eventid
    );

    mapping(bytes32 => Event) UserEvent;
    mapping(bytes32 => EventDetails) DetailsOfEvent;

    function createEvent(
        string memory Event_Name,
        string memory Date,
        string memory Timing,
        string memory Location,
        string memory Related_Sport,
        uint256 Max_participation
    ) public {
        bytes32 eventId = keccak256(bytes(Event_Name));
        Event storage newEvent = UserEvent[eventId];
        EventDetails storage NEWEvent = DetailsOfEvent[eventId];

        newEvent.EventName = Event_Name;
        newEvent.Date = Date;
        newEvent.Time = Timing;
        newEvent.Location = Location;
        newEvent.SportName = Related_Sport;
        newEvent.OrganiserId = msg.sender;
        newEvent.EventId = eventId;
        newEvent.Status = "Scheduled";
        newEvent.MAX_PARTICIPANTS_LIMIT = Max_participation;
        newEvent.Participants_WaitingList = 0;
        newEvent.head = 0;
        newEvent.length = 0;

        NEWEvent.EventName = Event_Name;
        NEWEvent.Date = Date;
        NEWEvent.Time = Timing;
        NEWEvent.Location = Location;
        NEWEvent.SportName = Related_Sport;
        NEWEvent.OrganiserId = msg.sender;
        NEWEvent.EventId = eventId;
        NEWEvent.Status = "Scheduled";
        NEWEvent.MAX_PARTICIPANTS_LIMIT = Max_participation;
        NEWEvent.Participants_WaitingList = 0;

        emit EventCreated(Event_Name, block.timestamp, Related_Sport, eventId);
    }

    function getEventDetails(string memory EventName)
        public
        view
        returns (EventDetails memory)
    {
        bytes32 eventId = keccak256(bytes(EventName));
        return DetailsOfEvent[eventId];
    }

    function JoinEvent(string memory EventName) public {
        bytes32 eventId = keccak256(bytes(EventName));
        // UserEvent[eventId].participant.push(msg.sender);
        node memory newNode = node(msg.sender, 0);
        bytes32 id = sha256(abi.encodePacked(UserEvent[eventId].length));

        UserEvent[eventId].Participants[id] = newNode;
        if (UserEvent[eventId].head == 0) {
            UserEvent[eventId].head = id;
        } else {
            bytes32 q = UserEvent[eventId].head;
            while (UserEvent[eventId].Participants[q].next != 0) {
                q = UserEvent[eventId].Participants[q].next;
            }
            UserEvent[eventId].Participants[q].next = id;
        }
        UserEvent[eventId].length++;
        updateParticipants(eventId);
    }

    function update_Event_Status(string memory EventName, uint256 eventStatus)
        public
    {
        bytes32 eventId = keccak256(bytes(EventName));
        require(
            msg.sender == UserEvent[eventId].OrganiserId,
            "You are Not A Owner of this Contract!"
        );
        require(eventStatus >= 0 && eventStatus < 3, "Invalide Status!");

        DetailsOfEvent[eventId].Status = status[eventStatus];
    }

    function LeaveEvent(string memory EventName) public {
        bytes32 eventId = keccak256(bytes(EventName));
        require(
            checkParticipation(msg.sender, eventId),
            "You Already Not Joined This Event!"
        );

        if (UserEvent[eventId].head == 0) {
            return;
        } else {
            bytes32 q = UserEvent[eventId].head;
            if (
                UserEvent[eventId].Participants[UserEvent[eventId].head].User ==
                msg.sender
            ) {
                UserEvent[eventId].head = UserEvent[eventId]
                    .Participants[UserEvent[eventId].head]
                    .next;
            } else {
                while (q != 0) {
                    if (
                        UserEvent[eventId]
                            .Participants[
                                UserEvent[eventId].Participants[q].next
                            ]
                            .User == msg.sender
                    ) {
                        UserEvent[eventId].Participants[q].next = UserEvent[
                            eventId
                        ]
                            .Participants[
                                UserEvent[eventId].Participants[q].next
                            ]
                            .next;
                        break;
                    }
                    q = UserEvent[eventId].Participants[q].next;
                }
            }
        }

        UserEvent[eventId].length--;
        updateParticipants(eventId);
    }
}
