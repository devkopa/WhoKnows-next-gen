import { pagesRepository } from "@/repositories/pagesRepository";

export const pagesService = {

    async findBySearch(searchString, language) {
        try {
            const results = await pagesRepository.findBySearch(searchString, language);
            return Array.isArray(results) ? results : [];
        } catch(error) {
            console.error('Service layer search error:', error)
            return [];
        }
    }

}