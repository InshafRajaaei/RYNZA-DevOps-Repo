// import mongoose from "mongoose";

// const connectDB = async () => {

//     mongoose.connection.on('connected',() => {
//         console.log("DB Connected");
        
//     })

//     await mongoose.connect(`${process.env.MONGODB_URL}/e-commerce`)

// }

// export default connectDB;

import mongoose from 'mongoose';

const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URL || 'mongodb://mongodb:27017/RYNZAdb';
    await mongoose.connect(mongoURI);
    console.log("DB Connected");
  } catch (error) {
    console.error("MongoDB Connection Error:", error.message);
    process.exit(1);
  }
};

export default connectDB;
