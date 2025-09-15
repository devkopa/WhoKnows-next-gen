import { userService } from "@/services/userService";
import { NextResponse, NextRequest } from "next/server";

export async function GET(request) {
    try {
        const { username, password } = await request.json();
        
        if (!username) {
            return NextResponse.json({ message: "Username cannot be empty." }, { status: 400 });
        }

        if (!password) {
            return NextResponse.json({ message: "Password cannot be empty." }, { status: 400 });
        }

        const user = await userService.login({ username, password });
        return NextResponse.json(user, { status: 200 });

    } catch (error) {
        return NextResponse.json({ message: error.message }, { status: 400 });
    }
}