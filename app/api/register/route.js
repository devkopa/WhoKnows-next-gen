import { userService } from "@/services/userService";
import { NextResponse } from "next/server";


export async function POST(request) {

    const { username, email, password } = await request.json();

    try{
        const user = await userService.register({username, email, password});

        return NextResponse.json({
            statusCode: 200,
            message: user.username + " has been registered"
        });
    } catch (error) {
    
    if (error.message.includes("username")) {
      return NextResponse.json({ statusCode: 422, message: "Username is already taken." });
    }

    if (error.message.includes("email")) {
      return NextResponse.json({ statusCode: 422, message: "Email is already taken." });
    }

    return NextResponse.json({ statusCode: 500, message: "Server error" });
  }
}