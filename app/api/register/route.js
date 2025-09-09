import { userService } from "@/services/userService";
import { NextResponse } from "next/server";


export async function POST(request) {

    const { username, email, password } = await request.json();

    try{
        const user = await userService.register({username, email, password});
        return NextResponse.json({
            statusCode: 200,
            message: "User " + user.username + " have been registered"
        });
    } catch(error) {
        return NextResponse.json({
            statusCode: 422,
            message: "Validation error"
        });
    }
    
}