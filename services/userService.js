import { userRepository } from "@/repositories/userRepository";



export const userService = {

    async getUserId(usernameReq) {
        if(typeof usernameReq === "string") {
            try {
                const userId = userRepository.getUserId(usernameReq);
                return Number.isInteger(userId) ? userId : -1;
            } catch(error) {
                console.error("Service layer error for getting user id: " + error);
                return null;
            }
        }
    }

}