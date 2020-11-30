import 'package:happy_helper/model/furniture.dart';
import 'package:happy_helper/service/item_service.dart';
import 'package:get_it/get_it.dart';

class BasketService {
  Map<Furniture, int> basket = new Map<Furniture, int>();

  ItemService _itemService = GetIt.I.get<ItemService>();

  void addToBasket(Furniture furni, int count) {
    if (basket.containsKey(furni)) {
      basket[furni] += count;
    } else {
      basket[furni] = count;
    }
  }

  void completeBasketItem(String key, List<BasketItem> basketItems) {
    List<RecipeItem> recipeItems = _itemService.getRecipeItemsFromKey(key);
    BasketItem bi = basketItems.firstWhere((x) => x.key == key);

    if (!bi.complete)
      bi.completedCount = 0;
    else
      bi.completedCount = bi.count;

    for (var r in recipeItems) {
      var child =
          basketItems.firstWhere(((x) => x.key == r.key), orElse: () => null);

      if (child != null && !child.complete) {
        if (bi.complete) {
          child.completedCount += r.count * bi.count;
          if (child.completedCount < 0) child.completedCount = 0;
          child.complete = child.completedCount >= child.count;
        } else {
          child.completedCount -= r.count * bi.count;
          if (child.completedCount < 0) child.completedCount = 0;
          child.complete = bi.completedCount >= bi.count;
        }
      }
    }
  }

  List<BasketItem> getBasketItems() {
    List<BasketItem> basketItems = new List<BasketItem>();

    for (var f in basket.keys) {
      basketItems.add(new BasketItem(f.key, f.name, basket[f], false));

      for (var r in f.recipe) {
        if (_itemService.getRecipeItemsFromKey(r.key).length > 0) {
          var bi = basketItems.firstWhere(((x) => x.key == r.key),
              orElse: () => null);

          if (bi == null) {
            basketItems
                .add(new BasketItem(r.key, r.name, r.count * basket[f], true));
          } else {
            bi.count += r.count * basket[f];
          }
        }
      }
    }

    return basketItems;
  }

  List<RecipeItem> getBasketMaterials(List<BasketItem> basketItems) {
    List<RecipeItem> basketMaterials = new List<RecipeItem>();

    for (var f in basket.keys) {
      if (basketItems.where((x) => x.key == f.key).first.complete) continue;

      for (var r in f.recipe) {
        var subItems = _itemService.getRecipeItemsFromKey(r.key);

        if (subItems.length == 0) {
          // that recipe item was already a material-level, add it to the list
          addBasketLineItem(r, basket[f], basketMaterials);
        } else {
          if (basketItems.where((x) => x.key == r.key).first.complete) continue;

          for (var subR in subItems) {
            addBasketLineItem(subR, basket[f] * r.count, basketMaterials);
          }
        }
      }
    }

    return basketMaterials;
  }

  void addBasketLineItem(
      RecipeItem r, int count, List<RecipeItem> basketMaterials) {
    if (basketMaterials.any((x) => x.key == r.key)) {
      // basket already contains this material, increment the count
      basketMaterials.firstWhere((x) => x.key == r.key).count +=
          r.count * count;
    } else {
      // this is a new item, add it to the list
      basketMaterials.add(new RecipeItem(r.key, r.name, r.count * count));
    }
  }

  void emptyBasket() {
    basket.clear();
  }
}
