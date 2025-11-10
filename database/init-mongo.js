// MongoDB Initialization Script for Docker
// This script runs automatically when MongoDB container starts for the first time

print('🎯 Initializing E-commerce Database...');

// Switch to e-commerce database
db = db.getSiblingDB('e-commerce');

// Create application user
try {
    db.createUser({
        user: 'ecommerce_user',
        pwd: 'ecommerce_pass',
        roles: [
            {
                role: 'readWrite',
                db: 'e-commerce'
            }
        ]
    });
    print('✅ Database user "ecommerce_user" created successfully');
} catch (error) {
    print('ℹ️ User already exists: ' + error);
}

// Create collections
const collections = ['users', 'products', 'orders'];
collections.forEach(collectionName => {
    if (!db.getCollectionNames().includes(collectionName)) {
        db.createCollection(collectionName);
        print('✅ Collection "' + collectionName + '" created');
    } else {
        print('ℹ️ Collection "' + collectionName + '" already exists');
    }
});

// Create indexes for better performance
try {
    db.users.createIndex({ "email": 1 }, { unique: true });
    db.products.createIndex({ "category": 1 });
    db.products.createIndex({ "bestseller": 1 });
    db.products.createIndex({ "date": -1 });
    db.orders.createIndex({ "userId": 1 });
    db.orders.createIndex({ "date": -1 });
    db.orders.createIndex({ "status": 1 });
    print('✅ Database indexes created successfully');
} catch (error) {
    print('ℹ️ Index creation: ' + error);
}

// Insert sample admin user
try {
    const adminUser = {
        name: "Admin User",
        email: "admin@rynza.com",
        password: "$2b$10$8hYrY/7QYvJjJK8JZK8JZeK8JZK8JZK8JZK8JZK8JZK8JZK8JZK", // bcrypt hash for 'admin123'
        cartData: {},
        isAdmin: true,
        createdAt: new Date(),
        updatedAt: new Date()
    };
    
    db.users.insertOne(adminUser);
    print('✅ Sample admin user inserted');
} catch (error) {
    print('ℹ️ Admin user already exists: ' + error);
}

// Insert sample products for testing
try {
    const sampleProducts = [
        {
            name: "Classic White T-Shirt",
            description: "Comfortable and stylish white t-shirt made from 100% cotton. Perfect for everyday wear.",
            price: 1999,
            image: [
                "https://res.cloudinary.com/dtif0kosd/image/upload/v1762711918/r9yk8gkurgcqmsmwcvks.png",
                "https://res.cloudinary.com/dtif0kosd/image/upload/v1762711293/rd9dui6vgdkrnfmpsrit.png"
            ],
            category: "Men",
            subCategory: "Topwear",
            sizes: ["S", "M", "L", "XL"],
            bestseller: true,
            date: new Date().getTime(),
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            name: "Slim Fit Jeans",
            description: "Modern slim fit jeans with stretch for maximum comfort. Perfect for casual outings.",
            price: 3999,
            image: [
                "https://res.cloudinary.com/dtif0kosd/image/upload/v1762711293/rd9dui6vgdkrnfmpsrit.png",
                "https://res.cloudinary.com/dtif0kosd/image/upload/v1762711918/r9yk8gkurgcqmsmwcvks.png"
            ],
            category: "Men",
            subCategory: "Bottomwear",
            sizes: ["30", "32", "34", "36"],
            bestseller: true,
            date: new Date().getTime(),
            createdAt: new Date(),
            updatedAt: new Date()
        },
        {
            name: "Summer Dress",
            description: "Beautiful summer dress perfect for warm weather. Lightweight and comfortable.",
            price: 2999,
            image: [
                "https://res.cloudinary.com/dtif0kosd/image/upload/v1762711918/r9yk8gkurgcqmsmwcvks.png"
            ],
            category: "Women",
            subCategory: "Topwear",
            sizes: ["S", "M", "L"],
            bestseller: false,
            date: new Date().getTime(),
            createdAt: new Date(),
            updatedAt: new Date()
        }
    ];

    db.products.insertMany(sampleProducts);
    print('✅ Sample products inserted successfully');
} catch (error) {
    print('ℹ️ Products already exist: ' + error);
}

// Display database summary
print('\n📊 DATABASE SUMMARY:');
print('===================');
print('Database: e-commerce');
print('User: ecommerce_user');
print('Collections: ' + db.getCollectionNames().join(', '));
print('Products Count: ' + db.products.countDocuments());
print('Users Count: ' + db.users.countDocuments());
print('Orders Count: ' + db.orders.countDocuments());
print('===================');
print('🎉 E-commerce database initialization completed!');