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

        uint256 productId = propertyIndex;
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

        propertyIndex = propertyIndex + 1;
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

        if (bytes(_propertyTitle).length > 0) {
            property.propertyTitle = _propertyTitle;
        }
        if (bytes(_category).length > 0) {
            property.category = _category;
        }
        if (bytes(_images).length > 0) {
            property.images = _images;
        }
        if (bytes(_propertyAddress).length > 0) {
            property.propertyAddress = _propertyAddress;
        }
        if (bytes(_description).length > 0) {
            property.description = _description;
        }

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
        Property[] memory items = new Property[](propertyIndex);

        for (uint256 i = 0; i < propertyIndex; i++) {
            Property storage currentItem = properties[i];
            items[i] = currentItem;
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
        uint256 itemCount = 0;
        for (uint256 i = 0; i < propertyIndex; i++) {
            if (properties[i].owner == user) {
                itemCount += 1;
            }
        }

        uint256 itemIndex = 0;
        Property[] memory items = new Property[](itemCount);
        for (uint256 i = 0; i < propertyIndex; i++) {
            if (properties[i].owner == user) {
                Property storage item = properties[i];
                items[itemIndex] = item;
                itemIndex += 1;
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

    function getProductReviews(
        uint256 productId
    ) external view returns (Review[] memory) {
        return reviews[productId];
    }

    function getUserReviews(
        address user
    ) external view returns (Review[] memory) {
        uint256 totalRewiews = userReviews[user].length;

        Review[] memory userProductReviews = new Review[](totalRewiews);
        for (uint256 i = 0; i < totalRewiews; i++) {
            uint256 productId = userReviews[user][i];
            Review[] memory productReviews = reviews[productId];

            for (uint256 j = 0; j < productReviews.length; j++) {
                if (productReviews[j].reviewer == user) {
                    userProductReviews[i] = productReviews[j];
                }
            }
        }

        return userProductReviews;
    }

    function likeReview(
        uint256 productId,
        uint256 reviewIndex,
        address user
    ) external {
        Review storage review = reviews[productId][reviewIndex];

        review.likes++;

        emit ReviewLiked(productId, reviewIndex, user, review.likes);
    }

    function getHighestRatedProduct() external view returns (uint256) {
        // find out which product has the most likes

        uint256 highestRating = 0;
        uint256 highestRatedProductId = 0;

        for (uint256 i = 0; i < reviewsCounter; i++) {
            uint256 productId = i + 1;

            if (products[productId].numReviews > 0) {
                uint256 avgRating = products[productId].totalRating /
                    products[productId].numReviews;

                if (avgRating > highestRating) {
                    highestRating = avgRating;
                    highestRatedProductId = productId;
                }
            }
        }

        return highestRatedProductId;
    }

    // #endregion Review
}
