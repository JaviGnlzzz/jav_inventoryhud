var Config = new Object();
var type = "normal";
var disabled = false;
var disabledFunction = null;
var ownerHouse = null;
var audio = new Audio('sonidos/sonido3.ogg');
audio.volume = 0.3;

Config.closeKeys = [113, 27, 90];

window.addEventListener("message", function (event) {
    if (event.data.action == "display") {

        audio.play()

        type = event.data.type

        disabled = false;

        const data = event.data

        if (type === "normal") {
            $('.inventory').css({'width' : '28.5vw' , 'transition' : '.45s'})
            $(".info-div-property").hide();
            $(".info-div-police").hide();
            $(".info-div").hide();
			$("#noSecondInventoryMessage").hide();
			$("#otherInventory").hide();
            $('#controls').show();
            $('#drop').show();
            $('#give').show();
            $('#use').show();
            $('.menu-lateral').show();
            $('#playerInventoryFastItems').fadeIn();
            $(".menu-lateral .boton").off("click").on("click", function(){
                let action = $(this).attr("action");
                let event = $(this).attr("event");
                $.post('https://jav_inventoryhud/inventory_options', JSON.stringify({event: event, action: action}));
            });

        } else if (type === "trunk") {
            $(".info-div-property").hide();
            $(".info-div-police").hide();
            $(".info-div").show();
            $("#otherInventory").show();
            $('#drop').hide();
            $('#give').hide();
            $('#use').hide();
            $('.inventory').css({'width' : '27vw' , 'transition' : '.45s'})
            $('.menu-lateral').hide();
            $('#playerInventoryFastItems').hide();
        } else if (type === "shop") {
            $(".info-div").show();
            $('.info-div').text('Tiendas 24/7');
            $("#otherInventory").show();
            $('#drop').hide();
            $('#use').hide();
            $('#give').hide();
            $('.inventory').css({'width' : '27vw' , 'transition' : '.45s'})
            $('.menu-lateral').hide();
            $('#playerInventoryFastItems').hide();
            $('#playerInventoryFastItems').hide();
        } else if (type === "property") {
            $(".info-div").hide();
            $(".info-div-property").show();
            $(".info-div-police").hide();
			$("#otherInventory").show();
            $('.menu-lateral').hide();
            $('#botonropa').hide();
            $('#cerrarropa').hide();
            $('.control3').hide();
            $('.control1').hide();
            $('.control2').hide();
            ownerHouse = event.data.owner;
        } else if (type === "storage") {
            $(".info-div").show();
            $('.info-div').text('Almacen - ' + data.job)
            $("#otherInventory").show();
            $('#drop').hide();
            $('#use').hide();
            $('#give').hide();
            $('.inventory').css({'width' : '27vw' , 'transition' : '.45s'})
            $('.menu-lateral').hide();
            $('#playerInventoryFastItems').hide();
            $('#playerInventoryFastItems').hide();
        } else if (type === "glovebox") {
            $(".info-div").show();
            $("#otherInventory").show();
        } else if (type === "player") {
            $(".info-div-property").hide();
            $(".info-div-police").hide();
            $(".info-div").show();
			$("#otherInventory").show();
        }

        $(".ui").fadeIn();
    } else if (event.data.action == "hide") {
        $("#dialog").dialog("close");
        $(".ui").fadeOut();
        $(".item").remove();
    } else if (event.data.action == "setItems") {
        inventorySetup(event.data.itemList,event.data.fastItems);

        $('.item').draggable({
            helper: 'clone',
            appendTo: 'body',
            zIndex: 99999,
            revert: 'invalid',
            start: function (event, ui) {
                if (disabled) {
                    return false;
                }

                $(this).css('background-image', 'none');
                itemData = $(this).data("item");
                itemInventory = $(this).data("inventory");
            },
            stop: function () {
                itemData = $(this).data("item");

                if (itemData !== undefined && itemData.name !== undefined) {
                    $(this).css('background-image', 'url(\'img/items/' + itemData.name + '.png\'');
                    $("#drop").removeClass("disabled");
                    $("#use").removeClass("disabled");
                    $("#give").removeClass("disabled");
                }
            }
        });
    } else if (event.data.action == "setSecondInventoryItems") {
        secondInventorySetup(event.data.itemList);
    } else if (event.data.action == "setShopInventoryItems") {
        shopInventorySetup(event.data.itemList)
    } else if (event.data.action == "setInfoText") {
        $(".info-div").html(event.data.text);
    } else if (event.data.action == "setInfoTextProp") {
        $(".info-div-property").html(event.data.text);
    } else if (event.data.action == "setInfoTextStorage") {
        $(".info-div-police").html(event.data.text);
    } else if (event.data.action == "nearPlayers") {
        $("#nearPlayers").html("");

        $.each(event.data.players, function (index, player) {
            $("#nearPlayers").append('<button class="nearbyPlayerButton" data-player="' + player.player + '">' + player.label + ' (' + player.player + ')</button>');
        });

        $("#dialog").dialog("open");

        $(".nearbyPlayerButton").click(function () {
            $("#dialog").dialog("close");
            player = $(this).data("player");
            $.post("http://jav_inventoryhud/GiveItem", JSON.stringify({
                player: player,
                item: event.data.item,
                number: parseInt($("#count").val())
            }));
        });
    }
    
    if (event.data.action == 'hotbar') {
        let items = event.data.items;

        for (let i = 0; i < 5; i++) {
            $(`#hotslot-${i + 1} img`).remove();
            $(`#hotslot-${i + 1} .hot-box-count`).remove();

            if (items[i] != undefined) {
                $(`#hotslot-${i + 1}`).append(`<img src="img/items/${items[i].name}.png" class="hot-item"/>`);
                $(`#hotslot-${i + 1}`).append(`<div class="hot-box-count">${items[i].count}</div>`);
            };

        };

        $("#hotbar").css({
            "opacity": "1",
            "bottom": '1vw',
        });
    }else if (event.data.action == 'hidehotbar') {
        $("#hotbar").css({
            "opacity": "0",
            "bottom": '-5vw',
        });
    }else if (event.data.action == 'hotbarused'){
        if (event.data.used != undefined) {

            $(`#hotslot-${event.data.used}`).css({'background-color' : 'rgba(2, 99, 2, 0.664)' , 'box-shadow' : '0 0 10px rgba(2, 99, 2, 0.664)' , 'border' : '.11vw solid green'});

            setTimeout(function(){
                $(`#hotslot-${event.data.used}`).css({'background-color' : '#131214' , 'border' : '.11vw solid rgb(190, 190, 190)' , 'box-shadow' : '0 0 10px #131214'});
            }, 1000)
        };
    };

    if(event.data.action == 'show:partearriba') {
        $('#peso-num').text(event.data.peso + '/' + event.data.pesoMax);
        $('.barra-progreso').css({'width' : (event.data.peso / event.data.pesoMax * 100) + '%'});
    };
});

function closeInventory() {
    $.post("http://jav_inventoryhud/NUIFocusOff", JSON.stringify({}));
}

function inventorySetup(items,fastItems) {
    $("#playerInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);

        $("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "z-index: 444; background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="item-count">' + count + '</div> </div ><div class="item-name-bg"></div></div>');
        $('#item-' + index).data('item', item);
        $('#item-' + index).data('inventory', "main");
    });
	$("#playerInventoryFastItems").html("");
    var i;
	for (i = 1; i < 6 ; i++) { 
	  $("#playerInventoryFastItems").append('<div class="slotFast"><div id="itemFast-' + i + '" class="item" >' +
            '<div class="keybind">' + i + '</div><div class="item-count"></div> </div ><div class="item-name-bg"></div></div>');
	}
	$.each(fastItems, function (index, item) {

        count = setCount(item);
		$('#itemFast-' + item.slot).css("background-image",'url(\'img/items/' + item.name + '.png\')');
		$('#itemFast-' + item.slot).html('<div class="keybind">' + item.slot + '</div><div class="item-count">' + count + '</div> <div class="item-name-bg"></div>');
        $('#itemFast-' + item.slot).data('item', item);
        $('#itemFast-' + item.slot).data('inventory', "fast");
    });
	makeDraggables()
}

function makeDraggables(){
	$('#itemFast-1').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "normal" && (itemInventory === "main" || itemInventory === "fast") && (itemData.type === 'item_weapon' || itemData.usable === true)) {
                disableInventory(500);

                $.post("http://jav_inventoryhud/PutIntoFast", JSON.stringify({
                    item: itemData,
                    slot : 1
                }));
            }
        }
    });
	$('#itemFast-2').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "normal" && (itemInventory === "main" || itemInventory === "fast") && (itemData.type === 'item_weapon' || itemData.usable === true)) {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoFast", JSON.stringify({
                    item: itemData,
                    slot : 2
                }));
            }
        }
    });
	$('#itemFast-3').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "normal" && (itemInventory === "main" || itemInventory === "fast") && (itemData.type === 'item_weapon' || itemData.usable === true)) {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoFast", JSON.stringify({
                    item: itemData,
                    slot : 3
                }));
            }
        }
    });
    $('#itemFast-4').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "normal" && (itemInventory === "main" || itemInventory === "fast") && (itemData.type === 'item_weapon' || itemData.usable === true)) {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoFast", JSON.stringify({
                    item: itemData,
                    slot : 4
                }));
            }
        }
    });
    $('#itemFast-5').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "normal" && (itemInventory === "main" || itemInventory === "fast") && (itemData.type === 'item_weapon' || itemData.usable === true)) {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoFast", JSON.stringify({
                    item: itemData,
                    slot : 5
                }));
            }
        }
    });
}

function secondInventorySetup(items) {
    $("#otherInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);

        $("#otherInventory").append('<div class="slotfix"><div id="itemOther-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="item-count">' + count + '</div> </div ><div class="item-name-bg"></div></div>');
        $('#itemOther-' + index).data('item', item);
        $('#itemOther-' + index).data('inventory', "second");
    });
}

function shopInventorySetup(items) {
    $("#otherInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);
        cost = setCost(item);

        $("#otherInventory").append('<div class="slotfix"><div id="itemOther-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="item-count">' + cost + count +  '</div> </div ><div class="item-name-bg"></div></div>');
        $('#itemOther-' + index).data('item', item);
        $('#itemOther-' + index).data('inventory', "second");
    });
}

function Interval(time) {
    var timer = false;
    this.start = function () {
        if (this.isRunning()) {
            clearInterval(timer);
            timer = false;
        }

        timer = setInterval(function () {
            disabled = false;
        }, time);
    };
    this.stop = function () {
        clearInterval(timer);
        timer = false;
    };
    this.isRunning = function () {
        return timer !== false;
    };
}

function disableInventory(ms) {
    disabled = true;

    if (disabledFunction === null) {
        disabledFunction = new Interval(ms);
        disabledFunction.start();
    } else {
        if (disabledFunction.isRunning()) {
            disabledFunction.stop();
        }

        disabledFunction.start();
    }
}

function setCount(item, second) {
    if (second && type === "shop") {
        return "$" + formatMoney(item.price);
    }

    count = item.count

    if (item.limit > 0) {
        count = item.count + " / " + item.limit;
    }


    if (item.type === "item_weapon") {
        if (count == 0) {
            count = "";
        } 
    }

    if (item.type === "item_account" || item.type === "item_money") {
        count = (item.count + '$');
    }

    return count;
}
function itemDescriptionOn(obj) {
    itemData = $(obj).data("item");
    if (itemData.label !== undefined) {
        var element = $("<div class='item-desc-info'><p><span id='item-name'>"+ itemData.label +"</span></p><hr class='item-hr'><p><span id='item-desc'>" + itemData.description + "</span></p><p><span id='item-amount'><span class='strong'>Hoeveelheid</span>: " + itemData.amount + "</span></p><p><span id='item-weight'><span class='strong'>Gewicht p.st.</span>: " + (itemData.weight / 1000).toFixed(2) + " kg</span></p></div>") .fadeIn(200);
        $("#item-information").html("");
        $("#item-information").append(element);
        setTimeout(function () {
            $(element).fadeOut(100, function () { $(this).remove(); });
        }, 3500);
    }
}

$(document).ready(function () {
    $("#count").focus(function () {
        $(this).val("")
    }).blur(function () {
        if ($(this).val() == "") {
            $(this).val("1")
        }
    });

    $("body").on("keyup", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeInventory();
        }
    });

    $('#use').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.usable) {
                disableInventory(300);
                $.post("http://jav_inventoryhud/UseItem", JSON.stringify({
                    item: itemData
                }));
            }
        }
    });
    

    $('#give').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.canRemove == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.canRemove) {
                disableInventory(300);
                $.post("http://jav_inventoryhud/GetNearPlayers", JSON.stringify({
                    item: itemData
                }));
            }
        }
    });

    $('#drop').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.canRemove == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.canRemove) {
                disableInventory(300);
                $.post("http://jav_inventoryhud/DropItem", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }
        }
    });

    $('#playerInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "trunk" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/TakeFromTrunk", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "property" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/TakeFromProperty", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val()),
					owner : ownerHouse
                }));
            } else if (type === "player" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/TakeFromPlayer", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }else if (type === "normal" && itemInventory === "fast") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/TakeFromFast", JSON.stringify({
                    item: itemData
                }));
            } else if (type === "glovebox" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/TakeFromGlovebox", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                })); 
            } else if (type === "storage" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/TakeFromStorage", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "shop" && itemInventory === "second") {
                disableInventory(500);
                console.log('Comprado')
                $.post("http://jav_inventoryhud/BuyItem", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "disc-property" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/TakeFromDiscProperty", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));

            }
        }
    });

    $('#otherInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "trunk" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoTrunk", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "property" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoProperty", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val()),
					owner : ownerHouse
                }));
            } else if (type === "glovebox" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoGlovebox", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "storage" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoStorage", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "disc-property" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoDiscProperty", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "player" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://jav_inventoryhud/PutIntoPlayer", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }
        }
    });
    $("#count").on("keypress keyup blur", function (event) {
        $(this).val($(this).val().replace(/[^\d].+/, ""));
        if ((event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    });
});

$.widget('ui.dialog', $.ui.dialog, {
    options: {
        clickOutside: false,
        clickOutsideTrigger: ''
    },
    open: function () {
        var clickOutsideTriggerEl = $(this.options.clickOutsideTrigger),
            that = this;
        if (this.options.clickOutside) {
            $(document).on('click.ui.dialogClickOutside' + that.eventNamespace, function (event) {
                var $target = $(event.target);
                if ($target.closest($(clickOutsideTriggerEl)).length === 0 &&
                    $target.closest($(that.uiDialog)).length === 0) {
                    that.close();
                }
            });
        }
        this._super();
    },
    close: function () {
        $(document).off('click.ui.dialogClickOutside' + this.eventNamespace);
        this._super();
    },
});
