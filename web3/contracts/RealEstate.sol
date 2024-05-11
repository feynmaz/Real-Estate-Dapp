// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract RealEstate {
    // #region Property
    // State
    struct Property {
        uint256 productID;
        address owner;
        uint256 price;
        string propertyTitle;
        string category;
        string images;
        string propertyAddress;
        string description;
        address[] reviewers;
        string[] reviews;
    }

    // Mapping
    mapping(uint256 => Property) private properties;
    uint256 public propertyIndex;

    // Events
    event PropertyListed(
        uint256 indexed id,
        address indexed owner,
        uint256 price
    );
    event PropertySold(
        uint256 indexed id,
        address indexed oldOwner,
        address indexed newOwner,
        uint256 price
    );
    event PropertyResold(
        uint256 indexed id,
        address indexed oldOwner,
        address indexed newOwner,
        uint256 price
    );

    // Functions
    function listProperty(
        address owner,
        uint256 price,
        string memory _propertyTitle,
        string memory _category,
        string memory _images,
        string memory _propertyAddress,
        string memory _description
    ) external returns (uint256) {
        require(price > 0, "Price must be greater than 0.");

        uint256 productId = propertyIndex++;
        Property storage property = properties[productId];

        property.productID = productId;
        property.owner = owner;
        property.price = price;
        property.propertyTitle = _propertyTitle;
        property.category = _category;
        property.images = _images;
        property.propertyAddress = _propertyAddress;
        property.description = _description;

        emit PropertyListed(productId, owner, price);

        return productId;
    }

    function updateProperty(
        address owner,
        uint256 productId,
        string memory _propertyTitle,
        string memory _category,
        string memory _images,
        string memory _propertyAddress,
        string memory _description
    ) external returns (uint256) {
        Property storage property = properties[productId];
        require(property.owner == owner, "You are not the owner.");

        property.propertyTitle = _propertyTitle;
        property.category = _category;
        property.images = _images;
        property.propertyAddress = _propertyAddress;
        property.description = _description;

        return productId;
    }

    function updatePrice(
        address owner,
        uint256 productId,
        uint256 price
    ) external returns (string memory) {
        Property storage property = properties[productId];

        require(property.owner == owner, "You are not the owner.");

        property.price = price;

        return "Your property price is updated";
    }

    function buyProperty(uint256 productId, address buyer) external payable {
        uint256 amount = msg.value;

        require(amount >= properties[productId].price, "Insufficient funds");

        Property storage property = properties[productId];

        (bool sent, ) = payable(property.owner).call{value: amount}("");

        if (sent) {
            address oldOwner = property.owner;
            property.owner = buyer;
            emit PropertySold(productId, oldOwner, buyer, amount);
        }
    }

    function getAllProperties() public view returns (Property[] memory) {
        uint256 itemsCount = propertyIndex;
        uint256 currentIndex = 0;

        Property[] memory items = new Property[](itemsCount);

        for (uint256 i = 0; i < itemsCount; i++) {
            uint256 currentId = i + 1;

            Property storage currentItem = properties[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
        }

        return items;
    }

    function getProperty(
        uint256 productId
    )
        external
        view
        returns (
            uint256,
            address,
            uint256,
            string memory,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        Property memory property = properties[productId];
        return (
            property.productID,
            property.owner,
            property.price,
            property.propertyTitle,
            property.category,
            property.images,
            property.propertyAddress,
            property.description
        );
    }

    function getUserProperty(
        address user
    ) external view returns (Property[] memory) {
        uint256 totalItemCount = propertyIndex;
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (properties[i + 1].owner == user) {
                itemCount += 1;
            }
        }

        Property[] memory items = new Property[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (properties[i + 1].owner == user) {
                uint256 currentId = i + 1;
                Property storage currentItem = properties[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }
    // #endregion Property

    // #region Review
    // State
    struct Review {
        address reviewer;
        uint256 prodcutId;
        uint256 rating;
        string comment;
        uint256 likes;
    }

    struct Product {
        uint256 productId;
        uint256 totalRating;
        uint256 numReviews;
    }

    uint256 public reviewsCounter;

    // Mapping
    mapping(uint256 => Review[]) private reviews;
    mapping(address => uint256[]) private userReviews;
    mapping(uint256 => Product) private products;

    // Events
    event ReviewAdded(
        uint256 indexed productId,
        address indexed reviewer,
        uint256 rating,
        string comment
    );
    event ReviewLiked(
        uint256 indexed productId,
        uint256 indexed reviewIndex,
        address indexed liker,
        uint256 likes
    );

    // Functions
    function addReview(
        uint256 productId,
        uint256 rating,
        string calldata comment,
        address user
    ) external {
        require(rating >= 1 && rating <= 5, "rating must be between 1 and 5");

        Property storage property = properties[productId];

        property.reviewers.push(user);
        property.reviews.push(comment);

        reviews[productId].push(Review(user, productId, rating, comment, 0));
        userReviews[user].push(productId);
        products[productId].totalRating += rating;
        products[productId].numReviews++;

        emit ReviewAdded(productId, user, rating, comment);

        reviewsCounter++;
    }

    function getProductReviews() external view returns (Review[] memory) {}

    function getUserReviews() external view returns (Review[] memory) {}

    function likeReview() external {}

    function getHighestRatedProduct() external view returns (uint256) {}
    // #endregion Review
}
